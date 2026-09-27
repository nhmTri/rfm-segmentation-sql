.PHONY: run test clean

PSQL ?= psql

run:            ## load the sample data and print the segments
	$(PSQL) -v ON_ERROR_STOP=1 -q -f sql/00_sample_data.sql
	$(PSQL) -f sql/rfm.sql

test:           ## run the query and compare against the expected output
	bash tests/test_rfm.sh

clean:          ## drop the sample table
	$(PSQL) -c "DROP TABLE IF EXISTS orders;"
