require_relative 'rubyscripts/archivist'

archivist = Archivist.new()
archivist.clear_database
archivist.setup_tables()
