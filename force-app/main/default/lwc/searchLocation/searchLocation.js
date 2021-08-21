import { LightningElement, track, wire} from 'lwc';
// import getLocation method from Apex Class ZomatoClass
import getLocation from '@salesforce/apex/ZomatoClass.getLocation';
// To fire an event using Publish–Subscribe Pattern, import CurrentPageReference and fireEvent
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
//Extend LightningElement to create a JavaScript class for a Lightning web component.
export default class Zomato extends LightningElement {
    location = '';
    entityId = '';
    entityType = '';
    // To read Salesforce CurrentPageReference, below reactive wire service has been used.
    @wire(CurrentPageReference) pageRef;
 
    /* Method to capture the value of entered location in the html input element */
    handleLocationChange(event) {
        this.location = event.target.value;
    }
    /* This Method will make Zomato REST API call through APEX to get the location details  
     * such as entity Id, entity type etc based on location name  
    */
    selectLocation() {
        getLocation({ 'locationName' : this.location })
        .then(result => {
            const output = JSON.parse(result);
            const location_suggestions = output.location_suggestions;
            this.error = undefined;
            if(location_suggestions !== undefined) {
                this.entityId = location_suggestions[0].entity_id;
                this.entityType = location_suggestions[0].entity_type;
                if(this.entityId != null && this.entityType != null){
                    fireEvent(this.pageRef,'displayRestaurantsPage',location_suggestions[0]);
                }  
            }
            else {
                console.log("No info returned in call back in selectLocation method");
            }
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!!',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            console.log("error", JSON.stringify(this.error));
        });
    }
}