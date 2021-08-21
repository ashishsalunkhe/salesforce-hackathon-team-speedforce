import { LightningElement, wire, track } from 'lwc';
// The pub-sub module checks for page references when firing events, 
// so that the event is scoped and only in the current page.
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
// Import custom labels
import zomatoApiUrl from '@salesforce/label/c.Zomato_API_URL';
import zomatoUserKey from '@salesforce/label/c.ZomatoAPIKey';
 
//Extend LightningElement to create a JavaScript class for a Lightning web component.
export default class SearchRestaurants extends LightningElement {
    @track restaurantsList =[];
    @wire(CurrentPageReference) pageRef;
     
    //In connectedCallback we subscribe to the event, In disconnectedCallback we un-subscribe.
    connectedCallback(){
        // Registers a callback for an event
        // @param {string} eventName - Name of the event to listen for.
        // @param {function} callback - Function to invoke when said event is fired.
        // @param {object} this - The value to be passed as the this parameter to the callback function is bound.
        registerListener('displayRestaurantsPage',this.handleRestaurantList,this);
    }
    disconnectedCallback(){        
        // Unregisters all event listeners bound to an object.
        // @param {object} this - All the callbacks bound to this object will be removed.
        unregisterAllListeners(this);
    }
 
    /* This method will make Zomato REST API callout through javaScript not APEX
    *  to get the best rated restaurants based on location(ie. entity id and entity type)
    */
    searchRestaurant(locationDetails) {
        let url = zomatoApiUrl;
        url = url+'location_details?entity_id='+locationDetails.entity_id;
        url = url+'&entity_type='+locationDetails.entity_type;
        //The Fetch API provides a JavaScript interface for accessing and manipulating parts of the HTTP pipeline, 
        //such as requests and responses.
        fetch(url,
        {
            method : "GET",
            headers : {
                "Content-Type": "application/json",
                "user-key": zomatoUserKey
            }
        })
        .then((response) => {
            if (!response.ok) {
              throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then((responseJSON) => {
            this.restaurantsList = responseJSON.best_rated_restaurant;
        })
        .catch((error) => {
            console.error('There has been a problem with your fetch operation:', error);
        }); 
    }
 
    handleRestaurantList(locationDetails){
        this.searchRestaurant(locationDetails);
    }
     
}