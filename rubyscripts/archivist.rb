require 'pg'

class Archivist

  attr_accessor :db

  @@database_name = 'linkedin'

  def initialize(name=@@database_name)
    self.db = PG.connect({ dbname: name, user: 'postgres' })
    puts name
  end

  def setup_tables
    # creates all the tables that the database needs
    self.db.exec(
      <<~HEREDOC

        CREATE TABLE employers (
          id serial,
          url VARCHAR,
          name VARCHAR,
          website VARCHAR,
          location VARCHAR,
          size VARCHAR,
          scrape_date TIMESTAMP NOT NULL DEFAULT NOW(),
          PRIMARY KEY(id)
        );

        CREATE TABLE people (
          id serial,
          url VARCHAR,
          first_name VARCHAR,
          last_name VARCHAR,
          current_job VARCHAR,
          country VARCHAR,
          further_location VARCHAR,
          employer_id INTEGER REFERENCES employers(id) ON DELETE CASCADE,
          scrape_date TIMESTAMP NOT NULL DEFAULT NOW(),
          PRIMARY KEY(id)
        );


      HEREDOC
    )
  end

  def clear_database
    self.db.exec(
      <<~HEREDOC
        DROP TABLE people;
        DROP TABLE employers;
      HEREDOC
    )
  end

  def show_table(name)
    self.db.exec(
      <<~HEREDOC
        SELECT * FROM #{name};
      HEREDOC
    )
  end

  def get_recent_people_urls
    # returnes a flat array of the last 10 urls logged
    self.db.exec(
      <<~HEREDOC
        SELECT url FROM people LIMIT 10;
      HEREDOC
    ).values.flatten()
  end

  def record_employer(data)
    # replaces the data for the current employer if it already exists
    # otherwise generates a new entery

    if employer_exists(data)
      update_employer(data)
    else
      insert_employer(data)
    end

  end

  def employer_exists(data)
    # checkes whether or not an employer with the same name exists in the employer relation
    self.db.exec(
      <<~HEREDOC
        SELECT *
        FROM employers
        WHERE name = '#{data[:name]}';
      HEREDOC
    ).ntuples > 0
  end

  def update_employer(data)
    # replaces the old matching employer data with new data (and an updated scrape data)
    self.db.exec(
      <<~HEREDOC
        UPDATE employers
        SET
          url = '#{data[:url]}',
          name = '#{data[:name]}',
          website = '#{data[:website]}',
          location = '#{data[:location]}',
          size = '#{data[:size]}',
          scrape_date = NOW()
        
        WHERE name = '#{data[:name]}';
      HEREDOC
    )
  end

  def insert_employer(data)
    self.db.exec(
      <<~HEREDOC
        INSERT INTO employers (
          url,
          name,
          website,
          location,
          size
        )
          VALUES (
          '#{data[:url]}',
          '#{data[:name]}',
          '#{data[:website]}',
          '#{data[:location]}',
          '#{data[:size]}'
        );
      HEREDOC
    )
  end

  def insert_person(data)
    self.db.exec(
      <<~HEREDOC
        INSERT INTO people (
            url,
            first_name,
            last_name,
            current_job,
            country,
            further_location,
            employer_id
        )
          VALUES (
            '#{data[:url]}',
            '#{data[:first_name]}',
            '#{data[:last_name]}',
            '#{data[:current_job]}',
            '#{data[:country]}',
            '#{data[:further_location]}',
            '#{data[:employer_id]}'
          );
      HEREDOC
    )
  end

  def get_all(name)
    # returns all the data from that database as an array (of arrays)
    ret = self.db.exec(
      <<~HEREDOC
        SELECT * FROM #{name};
      HEREDOC
    ).values
  end

end
