import { LightningElement, track, api, wire } from 'lwc';
import createCase from '@salesforce/apex/ContactCustomerSupportController.createCase';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import CASE_OBJECT from '@salesforce/schema/Case';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class ContactCustomerSupport extends LightningElement {
    @track error;
    @api recordId;
    @track status;
    @track cases={};
    @track statusPicklistOptions;
    @track contactCustomerWrapper;
    /*@track isChequeNoValid=false;
    @track validation={};
    @track eMatch;
    @track nachAmountcal;
    @track dateMatch;
    @track emiAmount;
    @track isEmiAmountValid=false;
    @track loanAmount;
    @track isEmiAmounValid;
    @track isStartDateDisabled=true;
    @track isEmiStartDateValid=false;*/

   
@wire(getObjectInfo, { objectApiName: 'Case' })
    caseMetadata;

//payment picklist
@wire(getPicklistValuesByRecordType, { recordTypeId: '$caseMetadata.data.defaultRecordTypeId', objectApiName: CASE_OBJECT })
statusPicklist({ error, data }) {
    if (data) {
        console.log('in kli type');
        console.log(data.picklistFieldValues.Status.values);
        this.statusPicklistOptions = data.picklistFieldValues.Status.values;

    } else if (error) {
        console.log(error);
        this.errorMessage = 'PLEASE_CONTACT_ADMIN';
    }
}
/*connectedCallback() {
       // this.getSubSchemeExistingData();
        this.getRepaymentData();
    }
    getRepaymentData(){
         console.log('this.recordId',this.recordId);
        getExistingRepaymentData({loanId: this.recordId}).then((data) => {
            console.log('reopayment: -- ',data);
            this.repaymentDetails.Mode_of_Payment__c = data.Mode_of_Payment__c
            this.repaymentDetails.Frequency__c =data.Frequency__c
            this.repaymentDetails.Cheque_No__c=data.Cheque_No__c
            this.repaymentDetails.EMI_Amount__c=data.EMI_Amount__c
            this.repaymentDetails.Tenure__c=data.Tenure__c
            this.repaymentDetails.NACH_Amount__c=data.NACH_Amount__c
            this.repaymentDetails.EMI_Start_Date__c=data.EMI_Start_Date__c
            this.repaymentDetails.EMI_End_Date__c=data.EMI_End_Date__c
        })
    }*/

    handleStatusPicklist(event) {

    if (event.target.name == "Status") {
        console.log('in resi tye');
        this.cases.Status = event.target.value;
        if (event.target.value != 'None' || event.target.value != '') {
            this.template.querySelector(".status").setCustomValidity("");
            this.template.querySelector(".status").reportValidity();
            
            console.log('in resi tye' + this.cases.Status);
        }
    }
}

// Saving the text feilds

handleCase(event) {

        
        if (event.target.dataset.targetId == 'caseAttribute') {
            this.cases[event.target.name] = event.target.value;

            this.cases['Id'] = this.recordId;
          // Show success messsage

     console.log('IN case cdata' + JSON.stringify(this.cases));
   }
}

/*validateNumberField(inputVal,className)
    {
        let ret = true;
        var iChars = "~`!#$%^&*+=[]\\\';/{}|\":<>?";
        console.log('inputVal--',inputVal);
        console.log('className--',className);
        console.log('inputVal.length--',inputVal.length);
        for (let idx = 0; idx < inputVal.length; idx++)
        { console.log('character');
            if (!(parseInt(inputVal.charCodeAt(idx)) >= 48 && parseInt(inputVal.charCodeAt(idx)) <= 57) && !(parseInt(inputVal.charCodeAt(idx)) >= 44 && parseInt(inputVal.charCodeAt(idx)) <= 45)){
            ret = false;
            console.log('valid ch')
            this.setCustomErrorMessages(className, 'Please enter only numbers, hyphens and commas.');
            }
            else if(inputVal.length > 256){
                    console.log('aa gyaaaa')
                    this.setCustomErrorMessages(className, 'Maximum limit is 256 characters.');
                    ret = false;
            }
        }
        return ret;
    }

handleChequeNoValues(event)
{

    let inputVal= event.target.value;

    if(event.target.name==='Cheque_No__c'){
        let isValid = this.validateNumberField(inputVal,'valField');
       if(isValid){ 
            
           this.isChequeNoValid=true;
           this.repaymentDetails['Cheque_No__c'] = event.target.value;
           this.validation['repaymentDetails.Cheque_No__c']=true;
           this.setCustomErrorMessages('valField','');
            
        }else{
            this.isChequeNoValid=false;
            this.validation['repaymentDetails.Cheque_No__c']=false;
        }
    }
}

handleNachAmount(event){
    let nAmount = 4;
    let EMI_amount = this.repaymentDetails.EMI_Amount__c;
    this.eMatch = EMI_amount * nAmount;
    console.log('match' +this.eMatch);
    this.repaymentDetails.NACH_Amount__c = this.eMatch;
}  

validateEmiStartDate(inputVal,className){
    let ret = true;
    console.log('inputVal--',inputVal);
    console.log('className--',className);

    let today = new Date();
    console.log('today');

    if(new Date(inputVal).getTime() < new Date().getTime()){
        console.log('new date');
        this.setCustomErrorMessages(className, 'EMI start date should be a future date');
        ret = false;
    }
    else{
        this.setCustomErrorMessages(className, '');
    }
    return ret;
}

handleEndDate(event){
    
    let tYear = parseInt(this.repaymentDetails.Tenure__c);
    console.log('tyear',tYear);
    let inputVal = event.target.value;
    console.log('input value',inputVal);
    let isValid = this.validateEmiStartDate(inputVal,'emistart');
    console.log('isvalid',isValid);
    if(isValid){
        this.isEmiStartDateValid = true;
        this.repaymentDetails['EMI_Start_Date__c'] = event.target.value;
        this.validation['repaymentDetails.EMI_Start_Date__c']=true;
        //this.setCustomErrorMessages('emistart',''); 
    }else{
        this.isEmiStartDateValid = false;
        this.validation['repaymentDetails.EMI_Start_Date__c']=false;
    }
    console.log('emi start date',this.repaymentDetails.EMI_Start_Date__c);
    let startDate = this.repaymentDetails.EMI_Start_Date__c;
    console.log('start date',startDate);

    var start = new Date(startDate);
    console.log('month',start.getMonth());
    // var year = start.getFullYear();
    // let date = year + tYear + '-' + (start.getMonth()) + '-' + start.getDate(); 
    
    let tempstartdate;
        let tempstartd;
        let tempd;
        let tempm;
        let tempmonth;
        let date;
        if(start.getMonth() === 4 || start.getMonth() === 6 || start.getMonth() === 9 || start.getMonth() === 11){
            if(start.getDate()===31){
                tempstartdate =1;
                tempmonth=start.getMonth()+1;
                date = start.getFullYear() + tYear + '-' + tempmonth + '-' + tempstartdate; 
            }
            else{
                date = start.getFullYear() + tYear + '-' + start.getMonth() + '-' + start.getDate();
            }
        }
        else if(start.getMonth()==0){
            tempstartd = start.getMonth() + 12;
            date = start.getFullYear() + tYear + '-' + tempstartd + '-' + start.getDate();
        }else if(start.getMonth()==2){
            if(start.getDate()===29 || start.getDate()===30 || start.getDate()===31){
                tempm = start.getMonth()+1;
                tempd = 1;
                date = start.getFullYear() + tYear + '-' + tempm + '-' + tempd;
            }else{
                date = start.getFullYear() + tYear + '-' + start.getMonth() + '-' + start.getDate();
            }
        }else{
            date = start.getFullYear() + tYear + '-' + start.getMonth() + '-' + start.getDate();
        }

    console.log('date match',date);
    this.repaymentDetails.EMI_End_Date__c = date;
    console.log('end date',this.repaymentDetails.EMI_End_Date__c)
}

validateEmiAmountField(inputVal,className)
    {
        let ret = true;
        let minLimit = this.label.MINIMUM_LOAN_AMOUNT;
        let maxLimit = this.label.MAXIMUM_LOAN_AMOUNT;
        // let minLimit = 200;
        // let maxLimit = 20000;
        console.log('inputVal--',inputVal);
        console.log('className--',className);
        console.log('inputVal.length--',inputVal.length);
        for (let idx = 0; idx < inputVal.length; idx++)
        { console.log('character');
            if (!(parseInt(inputVal.charCodeAt(idx)) >= 48 && parseInt(inputVal.charCodeAt(idx)) <= 57))
            {
            ret = false;
            console.log('valid ch')
            this.setCustomErrorMessages(className, 'Please enter number only.');
            
            }else if(inputVal < parseInt(minLimit) || inputVal > parseInt(maxLimit)){
                    console.log('aa gyaaaa')
                    this.setCustomErrorMessages(className, `Minimun EMI Amount is ${minLimit} and Maximum EMI Amount is ${maxLimit}.`);
                    ret = false;
            }
        }
        return ret;
    }

    handleEmiAmount(event)
    { 
        let inputVal= event.target.value;

        if(event.target.name==='EMI_Amount__c'){
            let isValid = this.validateEmiAmountField(inputVal,'emiAmount');
        if(isValid){ 
            this.isEmiAmountValid=true;
            this.repaymentDetails['EMI_Amount__c'] = event.target.value;
            this.validation['repaymentDetails.EMI_Amount__c']=true;
            this.setCustomErrorMessages('emiAmount','');
                
            }else{
                this.isEmiAmountValid=false;
                this.validation['repaymentDetails.EMI_Amount__c']=false;
            }
        }
    }*/


//Generic Toast Messgaes
showToast(Title, Message, Variant, Mode) {
    const event = new ShowToastEvent({
        title: Title,
        message: Message,
        variant: Variant,
        mode: Mode
    });
    this.dispatchEvent(event);
}

/*setCustomErrorMessages(fieldName, msg)
{
        let field = this.template.querySelector('.'+fieldName);
        field.setCustomValidity(msg);
        field.reportValidity();
    
}*/

// Save Repayment Details
/*handleSubmit(event) {
    this.template.querySelectorAll("lightning-input").forEach(input => {
        console.log('input.required'+input.required);     
        console.log('input.value',input.value);
        console.log('input.name',input.name);
           if(input.value === ""){
                this.validation[input.name] = false;
                input.setCustomValidity(`${input.label} is required`);
                input.reportValidity();
            }
            else
            {
                input.setCustomValidity("");
                this.validation[input.name] = true;
                input.reportValidity();

            }
            let inputVal = input.value;
            if(inputVal !== "" && input.name==='Cheque_No__c'){
                let isValid = this.validateNumberField(inputVal,'valField');
                if(isValid){     
                    this.repaymentDetails['Cheque_No__c'] = inputVal;
                    this.validation['repaymentDetails.Cheque_No__c']=true;
                    this.setCustomErrorMessages('valField','');   
                }else{
                    this.validation['repaymentDetails.Cheque_No__c']=false;
                }
            }else
                if(inputVal !== "" && input.name==='EMI_Amount__c'){
                let isValid = this.validateEmiAmountField(inputVal,'emiAmount');
                if(isValid){     
                    this.repaymentDetails['EMI_Amount__c'] = inputVal;
                    this.validation['repaymentDetails.EMI_Amount__c']=true;
                    this.setCustomErrorMessages('emiAmount','');   
                }else{
                    this.validation['repaymentDetails.EMI_Amount__c']=false;
                }
            }else if(inputVal!=="" && input.name==='EMI_Start_Date__c'){
                let isValid = this.validateEmiStartDate(inputVal,'emistart');
                if(isValid){
                    this.repaymentDetails['EMI_Start_Date__c'] = inputVal;
                    this.validation['repaymentDetails.EMI_Start_Date__c']=true;
                    //this.setCustomErrorMessages('emistart',''); 
                }else{
                    this.validation['repaymentDetails.EMI_Start_Date__c']=false;
                }

            }
        })

        console.log('result' );
        console.log('this.recordId'+this.recordId);
        //console.log('this.validationCheque_No__c',this.validation['repaymentDetails.Cheque_No__c']);
        console.log('this.EMI_Amount__c',this.validation['repaymentDetails.EMI_Amount__c']);
        console.log('this.EMI_Start_Date__c',this.validation['repaymentDetails.EMI_Start_Date__c']);
        console.log('this.Cheque_No__c',this.validation['repaymentDetails.Cheque_No__c']);
        if(this.repaymentDetails.Mode_of_Payment__c && this.repaymentDetails.Tenure__c){
        if(this.validation['repaymentDetails.EMI_Amount__c'] && this.validation['repaymentDetails.EMI_Start_Date__c'] && this.validation['repaymentDetails.Cheque_No__c']){
            insertRepaymentDetails({ repaymentWrapper: JSON.stringify(this.repaymentDetails), loanApplication :this.recordId }).then(result => {

            let data = result;
            console.log('result' + JSON.stringify(data));
            let isErrorOccured = data['isErrorOccured'];
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                message: 'Repayment Created Successfully!!',
                variant: 'success'
            }),
            );
            if (isErrorOccured === true) {
                console.log("permanent close", this.label.KOTAK_ERROR);
                this.showToast(this.label.KOTAK_ERROR, result["errorLog"]["Custom_Message__c"] + " " + "Ref No: " + result["errorLog"]["Name"], "error", "pester");
                this.repaymentWrapper['isErrorOccured'] = this.isErrorOccured;
            }
            else {
                
                this.repaymentWrapper['repaymentDetails'] = data['repaymentDetails'];
                console.log('repaymentWrapper in update' + this.repaymentWrapper['repaymentDetails']);
                this.repaymentDetails = data['repaymentDetails'];
                console.log('repaymentDetails in updated' + this.repaymentDetails);
            
            }
            }).catch(error => {
                this.showSpinner = false;
            // let ErrorMsg = JSON.parse(error.body.message);
            // this.showToast('Error.', 'Error', 'error', 'pester');

            }) 
    }else{
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error!!',
            message: 'Please enter valid details!!',
            variant: 'error'
        }));
    } 
}else{
    this.dispatchEvent(new ShowToastEvent({
        title: 'Error!!',
        message: 'Please enter valid details!!',
        variant: 'error'
    }));
}
}*/

handleSubmit(event){
    createCase({ contactCustomerWrapper: JSON.stringify(this.cases), recordId :this.recordId}).then(result => {

        let data = result;
        console.log('result' + JSON.stringify(data));
        //let isErrorOccured = data['isErrorOccured'];
        
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!',
            message: 'Case Created Successfully!!',
            variant: 'success'
        }),
        );

        this.contactCustomerWrapper['cases'] = data['cases'];
        console.log('contactCustomerWrapper in update' + this.contactCustomerWrapper['cases']);
        this.cases = data['cases'];
        console.log('case in updated' + this.cases);
        
        }).catch(error => {
            this.showSpinner = false;
        // let ErrorMsg = JSON.parse(error.body.message);
        // this.showToast('Error.', 'Error', 'error', 'pester');

        })

}

}