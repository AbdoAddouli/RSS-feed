public class NewsScheduler implements Schedulable {
    // Execute method for the schedulable interface
    public void execute(SchedulableContext sc) {
        GotDailyNews.retrieveAndInsertNews();
    }

    public with sharing class GotDailyNews {
        // Future method for asynchronous callout
        @future(callout=true)
        public static void retrieveAndInsertNews() {
            try {
                // HTTP callout to get the RSS feed
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://www.salesforce.com/blog/');
                req.setMethod('GET');
                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {
                    // Parse the XML from the RSS feed
                    Dom.Document doc = res.getBodyDocument();
                    Dom.XMLNode rss = doc.getRootElement();
                    Dom.XMLNode channel = rss.getChildElement('channel', null);
                    List<Dom.XMLNode> items = channel.getChildElements();

                    Date yesterday = System.today().addDays(-1);
                    for (Dom.XMLNode item : items) {
                        String title = item.getChildElement('title', null).getText();
                        String pubDate = item.getChildElement('pubDate', null).getText();
                        String link = item.getChildElement('link', null).getText();

                        // Convert pubDate to Date format
                        Date publicationDate = parseDate(pubDate);
                        if (publicationDate != yesterday) {
                            continue;  // Only process news from yesterday
                        }

                        // Check if the news already exists
                        List<New__c> existingNews = [SELECT Id FROM New__c WHERE Title__c = :title AND PublicationDate__c = :publicationDate];
                        if (existingNews.isEmpty()) {
                            // Insert new news record
                            New__c newNews = new New__c(
                                Title__c = title,
                                PublicationDate__c = publicationDate,
                                Link__c = link
                            );
                            insert newNews;
                        }
                    }
                }
            } catch (Exception ex) {
                System.debug('Error: ' + ex.getMessage());
            }
        }

        // Helper method to convert RSS date format to Date
        public static Date parseDate(String rssDate) {
            try {
                DateTime dt = DateTime.valueOf(rssDate); // Adjust the format based on your RSS feed
                return dt.date();
            } catch (Exception e) {
                System.debug('Date Parsing Error: ' + e.getMessage());
                return null;
            }
        }
    }
}
