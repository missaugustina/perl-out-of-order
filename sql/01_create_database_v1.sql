-- sql to create the database and the tables

-- TODO: need additional report fields
-- TODO: status should be ENUM
CREATE TABLE reports (
  name            varchar(100) PRIMARY KEY,
  status          varchar(60) DEFAULT 'pending',
  start_date      varchar(100),
  end_date        varchar(60),
  submitted_on    timestamp DEFAULT current_timestamp,
  modified_on     timestamp,
  completed_on    timestamp,
  report_fields_json   varchar(1000)
);

CREATE INDEX reports_name_idx ON reports(name);

/* create test data */
INSERT INTO reports (name, start_date, end_date) VALUES ('foo_123', '01-01-2013', '01-02-2013');

CREATE TABLE images (
  id  varchar(3) PRIMARY KEY,
  image bytea
);