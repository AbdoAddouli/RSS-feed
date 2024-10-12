public with sharing class RecentNewsController {
    @AuraEnabled(cacheable=true)
        public static List<New__c> getRecentNews() {
            return [SELECT Id, Title__c, PublicationDate__c, Link__c FROM New__c ORDER BY PublicationDate__c DESC LIMIT 3];
        }
}
