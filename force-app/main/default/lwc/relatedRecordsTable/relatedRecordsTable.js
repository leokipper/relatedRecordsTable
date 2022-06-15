import { LightningElement, api} from 'lwc';
import checkTotalRecords from '@salesforce/apex/RelatedRecordsTableController.checkTotalRecords';
import getRecordsById  from '@salesforce/apex/RelatedRecordsTableController.getRecordsById';

const columns = [
    { label: 'Name', fieldName: 'recordUrl', type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        } 
    }
];

export default class RelatedRecords extends LightningElement {
    @api recordId;
    columns = columns;
    data = [];
    error;
    querySecondObj = false;
    totalRecords = 0;
    totalRecordsB = 0;
    lastRecordId = null;
    loadMoreStatus;
    targetDatatable;

    connectedCallback() {
        this.checkTotal();
    }

    checkTotal(){
        //Check how many records are childs of A (B and its related childs C)
        checkTotalRecords({parentId: this.recordId})
            .then(result => {
                this.totalRecordsB = result[0];
                this.totalRecords = result[0] + result[1];
                //Retrieve first set of records
                if(this.totalRecords > 0){
                    this.getRecordsById();
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    getRecordsById() {
        //Logic to check if all records off B object have been retrieved, then start to retrieve
        // B's child records (from object C)
        if(this.data.length === this.totalRecordsB){
            this.lastRecordId = null;
            this.querySecondObj = true;
        }
        getRecordsById({parentId: this.recordId, lastRecordId : this.lastRecordId, querySecondObj : this.querySecondObj})
            .then(result => {
                //Fill recordUrl with records URL to navigate to record
                result.forEach(record => {
                    record.recordUrl = '/' + record.Id;
                });

                //Append existing records array with the new set of retrieved records
                this.data = [...this.data, ...result];
                this.error = undefined;
                this.loadMoreStatus = '';
                if (this.targetDatatable && this.data.length >= this.totalRecords) {
                    //Stop Infinite Loading when all records have been retrieved
                    this.targetDatatable.enableInfiniteLoading = false;
                    //Display "All records loaded" when all records have been retrieved
                    this.loadMoreStatus = 'All records loaded';
                }
                //Disable the Loading spinner
                if (this.targetDatatable){
                    this.targetDatatable.isLoading = false;
                }
            })
            .catch(error => {
                this.error = error;
                this.data = undefined;
            });
    }

    onLoadMoreHandler(event) {
        //Display loading spinner
        event.target.isLoading = true;
        //Set the onloadmore event target to make it visible (disabling enableInfiniteLoading and isLoading).
        this.targetDatatable = event.target;
        //Set lastRecordId with the last Id returned. This is used to query the next set of records
        this.lastRecordId = this.data.slice(-1)[0].Id;
        // Get new set of records
        this.getRecordsById();
    }
}