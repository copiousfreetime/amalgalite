module ActiveRecord
  module ConnectionAdapters
    module Amalgalite
      module DatabaseStatements
        #--
        # DATABASE STATEMENTS ======================================
        #++

        def explain(arel, binds = [])
          sql = "EXPLAIN QUERY PLAN #{to_sql(arel, binds)}"
          SQLite3::ExplainPrettyPrinter.new.pp(exec_query(sql, "EXPLAIN", []))
        end

        # This diverges from the ActiveRecord::ConnectionAdapter::SQLite3Adapter
        # Amalgalite::Statement does not have the same methods as SQLite3::Statement
        # so we needed to use the Amalgalite names
        def exec_query(sql, name = nil, binds = [], prepare: false)
          type_casted_binds = type_casted_binds(binds)

          log(sql, name, binds, type_casted_binds) do
            ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
              # Don't cache statements if they are not prepared
              unless prepare
                stmt = @connection.prepare(sql)
                begin
                  cols = stmt.result_fields
                  unless without_prepared_statement?(binds)
                    stmt.bind(type_casted_binds)
                  end
                  records = stmt.all_rows
                ensure
                  stmt.close
                end
              else
                cache = @statements[sql] ||= {
                  stmt: @connection.prepare(sql)
                }
                stmt = cache[:stmt]
                cols = cache[:cols] ||= stmt.result_fields
                stmt.reset!
                stmt.bind(type_casted_binds)
                records = stmt.all_rows
              end

              ActiveRecord::Result.new(cols, records)
            end
          end
        end

        def exec_delete(sql, name = "SQL", binds = [])
          exec_query(sql, name, binds)
          @connection.total_changes
        end
        alias :exec_update :exec_delete

        def last_inserted_id(_result)
          @connection.last_insert_rowid
        end

        def execute(sql, binds = [], name = nil) #:nodoc:
          log(sql, name) do
            ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
              @connection.execute(sql, binds)
            end
          end
        end

        def begin_db_transaction #:nodoc:
          log("begin transaction", nil) { @connection.transaction }
        end

        def commit_db_transaction #:nodoc:
          log("commit transaction", nil) { @connection.commit }
        end

        def exec_rollback_db_transaction #:nodoc:
          log("rollback transaction", nil) { @connection.rollback }
        end
      end
    end
  end
end
