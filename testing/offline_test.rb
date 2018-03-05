require "minitest/autorun"

require_relative '../rubyscripts/archivist'

TEST_DB = 'linkedin_test'

SAMPLE_EMPLOYER = {
  name: 'Newgate Communications – Australia',
  url: 'https://www.linkedin.com/company/3267679/?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_view_base%3B3QBculZ%2FRlGYHpYZiif6gw%3D%3D&licu=urn%3Ali%3Acontrol%3Ad_flagship3_profile_view_base-background_details_company',
  location: 'Sydney, NSW',
  size: '1000-5000 employees',
  website: 'http://www.newgatecomms.com.au'
 }

 SAMPLE_PERSON =  {
   url: 'https://www.linkedin.com/in/sophie-mitchell-447471a1/',
   first_name: 'Sophie',
   last_name: 'Mitchell',
   current_job: 'Associate Partner at Newgate Communications – Australia',
   country: 'Australia',
   further_location: 'Melbourne',
   employer_id: 1
 }

class OfflineTests < Minitest::Test

  def setup
    @archivist = Archivist.new(TEST_DB)
    @archivist.setup_tables
  end

  def test_archivist_makes_and_kills_tables
    @archivist.clear_database
    assert_raises('ERROR') { @archivist.show_table('people') }
    assert_raises('ERROR') { @archivist.show_table('employers') }
    @archivist.setup_tables
    assert @archivist.show_table('people')
    assert @archivist.show_table('employers')
  end

  def test_archivist_inserts_employer
    @archivist.insert_employer(SAMPLE_EMPLOYER)
    refute_empty @archivist.get_all('employers')
    assert_equal "1", @archivist.get_all('employers')[0][0]
  end

  def test_archive_inserts_person
    @archivist.insert_employer(SAMPLE_EMPLOYER)
    @archivist.insert_person(SAMPLE_PERSON)
    @archivist.get_all('people')
    assert_equal "1", @archivist.get_all('people')[0][0]
  end

  def test_archivist_gets_recent_urls
    @archivist.insert_employer(SAMPLE_EMPLOYER)
    @archivist.insert_person(SAMPLE_PERSON)
    assert @archivist.get_recent_people_urls()
    assert_equal "https://www.linkedin.com/in/sophie-mitchell-447471a1/", @archivist.get_recent_people_urls()[0]
  end

  def teardown
    @archivist.clear_database()
  end

end
