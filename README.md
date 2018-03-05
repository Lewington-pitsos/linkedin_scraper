# LinkedIn Scraper

What it says on the tin: logs in to linkedin using a dummy account, and scrapes data from other account's linkedin profiles. This is a purely academic exercise, attempted because I found LinkedIn a hard website to scrape. I can't imagine how any of this data could be commercially useful.

### The scraping process goes as follows:
  1. Login using the dummy account.
  2. Access a profile url from one of the last 10 profiles scraped (or a randomly selected pre-defined url if the database is empty).
  3. Navigate to the url for the employer of the current profile, gather all it's data and record it in the database.

		Sometimes these employers aren't actually registered with Linkedin. In such cases we just log the employer's name and return to the employee.
  4. Return to the profile url, gather all it's data and record it in the database.
  5. Select a new profile from the list of "People Also Viewed" profiles and visit it.

		If the profile doesn't have one of those lists, return to 2.
  6. Return to step 3., wash, rinse and repeat.
