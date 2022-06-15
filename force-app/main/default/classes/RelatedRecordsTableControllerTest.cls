/**
 * Test class for RelatedRecordsTableController
 * @author LeonardoKipper
 */
@isTest
private class RelatedRecordsTableControllerTest {

    @TestSetup
    static void insertRecords(){
        List<A__c> aLst = new List<A__c>();
        List<B__c> bLst = new List<B__c>();
        List<C__c> cLst = new List<C__c>();
        for(Integer count = 0; count < 3; count++){
            aLst.add(new A__c(Name = 'A.'+count));
            cLst.add(new C__c(Name = 'C.'+count));
        }
        insert aLst;

        for(Integer count = 0; count < 4997; count++){
            if (math.mod(count, 5) == 0){
                bLst.add(new B__c(Name = 'B.'+count, A__c = aLst[0].Id));
            } else if (math.mod(count, 2) == 0) {
                bLst.add(new B__c(Name = 'B.'+count, A__c = aLst[1].Id));
            } else {
                bLst.add(new B__c(Name = 'B.'+count, A__c = aLst[2].Id));
            }
        }
        insert bLst;

        for(Integer count = 0; count < 4997; count++){
            if (math.mod(count, 5) == 0){
                cLst.add(new C__c(Name = 'C.'+count, B__c = bLst[0].Id));
            } else if (math.mod(count, 2) == 0) {
                cLst.add(new C__c(Name = 'C.'+count, B__c = bLst[1].Id));
            } else {
                cLst.add(new C__c(Name = 'C.'+count, B__c = bLst[2].Id));
            }
        }
        insert cLst;
    }

    /**
     * Test method for checkTotalRecords
     * @author LeonardoKipper
     */
    @IsTest
    static void checkTotalRecords(){
        A__c aRecord = [SELECT Id, (SELECT Id FROM B__r) FROM A__c ORDER BY Id ASC LIMIT 1];
        Test.startTest();
            List<Integer> totalRecordsLst = RelatedRecordsTableController.checkTotalRecords(aRecord.Id);
            System.assertEquals(aRecord.B__r.size(), totalRecordsLst[0]);
            System.assertEquals(1000, totalRecordsLst[0]);
            System.assertEquals(1000, totalRecordsLst[0]);
        Test.stopTest();
    }

    /**
     * Test method for getRecordsById
     * @author LeonardoKipper
     */
    @IsTest
    static void getRecordsById(){
        //First A record has 1000 B childs and 1000 C childs.
        A__c aRecord = [SELECT Id, (SELECT Id FROM B__r) FROM A__c Order By Id ASC LIMIT 1];
        Test.startTest();
            List<sObject> relatedObjs = RelatedRecordsTableController.getRecordsById(aRecord.Id, null, false);
            System.assertEquals(RelatedRecordsTableController.retrieveLimit, relatedObjs.size());
            relatedObjs = RelatedRecordsTableController.getRecordsById(aRecord.Id, null, true);
            System.assertEquals(RelatedRecordsTableController.retrieveLimit, relatedObjs.size());
        Test.stopTest();
    }
}