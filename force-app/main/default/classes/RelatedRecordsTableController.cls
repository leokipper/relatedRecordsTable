/**
 * Controller used in relatedRecordsTable LWC component
 * @author LeonardoKipper
 */
public class RelatedRecordsTableController {

    public static Integer retrieveLimit = 25;
    /**
     * Returns a list with total numbers of child recods (B and C related to parent A)
     * Used in relatedRecordsTable LWC component
     * @author LeonardoKipper
     * @param  parentId  Id of record A (used to count related childs)
     * @return List<Integer>   Position 0 = B totals, Position 1 = C totals
     */
    @AuraEnabled
    public static List<Integer> checkTotalRecords(Id parentId) {
        AggregateResult[] totalB = [SELECT Count(Id) FROM B__c WHERE A__c = :parentId];
        AggregateResult[] totalC = [SELECT Count(Id) FROM C__c WHERE B__c IN 
            (SELECT Id FROM B__c WHERE A__c = :parentId)];

        return new List<Integer>{(Integer) totalB[0].get('expr0'), (Integer) totalC[0].get('expr0')};
    }

    /**
     * Returns a list of sObjects of child recods (B or C related to parent A)
     * Used in relatedRecordsTable LWC component
     * @author LeonardoKipper
     * @param  parentId  Id of record A (used to search related childs)
     * @param  lastRecordId  Id of last retrieved record (used to order and find next set of records)
     * @param  querySecondObj  Boolean (if true switch the query to C records, childs of related B)
     * @return  List<sObject>    List of related sObjects (B or C)
     */
    @AuraEnabled
    public static List<sObject> getRecordsById(Id parentId, Id lastRecordId, Boolean querySecondObj) {
        if(!querySecondObj ){
            return [SELECT Id, Name
                    FROM B__c WHERE A__c = :parentId AND Id > :lastRecordId ORDER BY Id ASC LIMIT :retrieveLimit];
        } else {
            return [SELECT Id, Name
                    FROM C__c WHERE B__c IN (SELECT Id FROM B__c WHERE  A__c = :parentId) AND Id > :lastRecordId ORDER BY Id ASC LIMIT :retrieveLimit];
        }
    }
}