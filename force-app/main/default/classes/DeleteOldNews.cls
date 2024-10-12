public class DeleteOldNews  {
    private void deleteOldNews() {
        Date fourMonthsAgo = System.today().addMonths(-4);
        List<New__c> oldNews = [SELECT Id FROM New__c WHERE PublicationDate__c < :fourMonthsAgo];
        delete oldNews;
    }
}
