global without sharing class MetroScheduleCtrl {

    static final String error = 'ERROR';
    static final String success = 'SUCCESS';
    static final String srcDepartTime = 'SOURCEDEPTTIME';
    static final String destArrTime = 'DESTARRTIME';
	static final String BOOK = 'BOOK';    
    static final String AMOUNTDEDUCTIONSUCCESS = 'Deducted SuccessFully';
    static final String INSUFFICIENTBALANCE = 'Insuffcient Balance';
    static final String SEATNOTAVAILABLE = 'Seats Not Available';
    @AuraEnabled
    public static List<String> getMetroSlots() {
        List<String> metroSlots = new List<String>();
        metroSlots = Label.MetroLinkPune_Active_Slots.split(',');
        System.debug('active slots->' + metroSlots);
        return metroSlots;
    }
    
    @AuraEnabled
    public static Map<String, List<MetroSlot__c>>  getAvailableMetros(String source, String dest, Date journeyDate, String slot) {
        System.debug('source' + source);
        System.debug('dest' + dest);
        System.debug('journeyDate' + journeyDate);
        System.debug('slot' + slot);
        Map<String, List<MetroSlot__c>> returnMap = new Map<String, List<MetroSlot__c>>();
        List<MetroSlot__c> metroSlots = new List<MetroSlot__c>();
        List<MetroStationJunction__c> metroStat = new List<MetroStationJunction__c>();
        List<Id> metroTrainIds = new List<Id>();
        try {
            if(String.isNotBlank(source) && String.isNotBlank(dest) && (journeyDate!=null) && String.isNotBlank(slot)) {
               metroStat = [select id, Metro_Train__r.Metro_Name__c, Metro_Train__r.Metro_Type__c, Station__r.Station_Code__c, 
                            Station__r.Metro_Station_Name__c from MetroStationJunction__c where 
                            Station__r.Metro_Station_Name__c =:source or Station__r.Metro_Station_Name__c=:dest];
                if(metroStat!=null) {
                    if(metroStat.size() == 1) {
                        returnMap.put(error, new List<MetroSlot__c>());
                    } else if(metroStat.size() >1 ){
                        for(MetroStationJunction__c metroStatObj : metroStat) {
                            if(source.equalsIgnoreCase(metroStatObj.Station__r.Metro_Station_Name__c) && metroStatObj.Metro_Train__c!=null) {
                            	metroTrainIds.add(metroStatObj.Metro_Train__c);   
                            }
                        }
                        if(metroTrainIds.size() > 0) {
                            metroSlots = getMetroSlot(metroTrainIds, slot);                            
                            if(metroSlots.size() > 0) {
                                returnMap.put(success, metroSlots);
                            }  else {
                                returnMap.put(error, new List<MetroSlot__c>());                                
                            }
                        } else {
                            returnMap.put(error, new List<MetroSlot__c>());
                        } 
                        //returnMap.put(success, metroStat);
                    } else {
                        //returnMap.put(error, new List<MetroStationJunction__c>());
                    }
                } else {
                    //returnMap.put(error, new List<MetroStationJunction__c>());
                }
            } else {
                System.debug('Parameter Seems to be improper');
            }
        } catch(exception ex) {
            System.debug('Exception in MetroSchedule' + ex.getLineNumber() + ex.getCause());
        }
        System.debug('returnMap->' + returnMap);
        return returnMap;
    }
    
    @AuraEnabled
    public static List<Station__c> getMetroStations() {
        List<Station__c> metroStations = new List<Station__c>();
        metroStations = [select id, Station_Code__c, Metro_Station_Name__c from Station__c];
        System.debug('metro Station->' + metroStations);
        return metroStations;
    }
    
    private static List<MetroSlot__c> getMetroSlot(List<Id> metroTrainIds, String slot) {
        List<MetroSlot__c> metroSlots = [select id, ArrivalTime__c,  Metro_Train__r.Metro_Name__c,Metro_Train__r.Metro_Type__c, DepartureTime__c, Name, VacantSeats__c  from MetroSlot__c where
                                         Metro_Train__c in :metroTrainIds and Name=:slot];
        System.debug('metroSlots->' + metroSlots);
        return metroSlots;
    }
    
    @AuraEnabled
    public static Map<String, Time> getArrivalDepartureTimes(String sourceSearch, String destSearch, String metroSlotId) {
    	Map<String, Time> timeMap = new Map<String, Time>();   
        System.debug('**' + sourceSearch);
        System.debug('**' + destSearch);
        System.debug('**' + metroSlotId);
        try {
            if(!String.isEmpty(sourceSearch) && !String.isEmpty(destSearch) && !String.isEmpty(metroSlotId)) {
                MetroSlot__c metSlot = [select id, Metro_Train__c from MetroSlot__c where id=:metroSlotId limit 1];
                System.debug('metSlot' + metSlot);
                List<MetroStationJunction__c> metStatJunc = [select id, Arrival__c, Departure__c, Station__r.Metro_Station_Name__c from MetroStationJunction__c where 
                                                             Metro_Train__c =: metSlot.Metro_Train__c and (Station__r.Metro_Station_Name__c=:sourceSearch or Station__r.Metro_Station_Name__c=:destSearch)];
                System.debug('metStatJunc' + metStatJunc);
                for(MetroStationJunction__c obj : metStatJunc) {
                    if(sourceSearch.equalsIgnoreCase(obj.Station__r.Metro_Station_Name__c)) {
                        timeMap.put(srcDepartTime, obj.Departure__c);
                    } else if(destSearch.equalsIgnoreCase(obj.Station__r.Metro_Station_Name__c)) {
                        timeMap.put(destArrTime, obj.Arrival__c);
                    }
                }
                System.debug('timeMap->' + timeMap);        
            }            
        } catch(Exception ex) {
            System.debug('Exception in MetroSchedule' + ex.getLineNumber() + ex.getCause());
        }
        System.debug('before return timeMap->' + timeMap);
        return timeMap;
    }
    
    @AuraEnabled
    public static Map<String, String> getUserData() {
        Map<String, String> userDataMap = new Map<String, String>();
        userDataMap.put('userId', UserInfo.getUserId());
        userDataMap.put('FirstName', UserInfo.getFirstName());
        User u = [select id, ContactId, Email, Username from user where id=:UserInfo.getUserId()];
        System.debug('user->' + u);
        System.debug('u.Id' + u.id);
        System.debug('contactId' + u.ContactId);
        userDataMap.put('contactId', u.ContactId);
        userDataMap.put('email', u.Email);
        userDataMap.put('UserName', u.Username);
        System.debug('userDataMap Before Return->' + userDataMap);
        return userDataMap;
    }
    
    @AuraEnabled
    public static integer getMaxTicketToBook() {
        return Integer.valueOf(Label.Max_Ticket_To_Book_Config);
    }
    
    @AuraEnabled
    public static Map<String, String> bookTicket(String source, String destination, Date journeyDay, String metroSlot, String contactId, String customerName, String ticketUser, integer seatCnt) {
        Map<String, String> bookStatusMap = new Map<String, String>();
        Map<String, String> amountDeductMap = new Map<String, String>();
        integer stationNumbersPassed = 0;
        System.debug('booking ticket');
        System.debug('source' + source);
        System.debug('destination' + destination);
        System.debug('journeyDay' + journeyDay);
        System.debug('metroSlot' + metroSlot);
        System.debug('contactId' + contactId);
        System.debug('customerName' + customerName);
        System.debug('ticketUser' + ticketUser);
        System.debug('seatCnt' + seatCnt);
        try {
            if(!String.isEmpty(source) && !String.isEmpty(ticketUser) && !String.isEmpty(destination) && !String.isEmpty(metroSlot) && !String.isEmpty(contactId) && !String.isEmpty(customerName) && journeyDay!=null && seatCnt > 0) {
                Ticket__c ticket = new Ticket__c();
                ticket.Ticket_Belongs_to__c = ticketUser;
                ticket.MetroSlot__c = metroSlot;
                ticket.SourceLocation__c = source;
                ticket.DestinationLocation__c = destination;
                ticket.Contact__c = contactId;
                ticket.Valid_for_Number_of_People__c = seatCnt;
                ticket.BookingTime__c = DateTime.now();
                stationNumbersPassed = getNumberofStatTravelled(source, destination);
                if(stationNumbersPassed > 0) {
                    ticket.Number_of_Passing_Stations__c = stationNumbersPassed;                    
                } else {
                    ticket.Number_of_Passing_Stations__c = 0;                    
                }
                if(updateSeatAvailability(metroSlot, BOOK, seatCnt)) {
                    insert ticket;
                    System.debug('ticket fare->' + ticket.Ticket_Fare__c);
                    amountDeductMap = updateCustomerWallet(contactId, stationNumbersPassed * seatCnt * Integer.valueOf(Label.Standard_Ticket_Fare_Label));
                    if(amountDeductMap!=null && amountDeductMap.get('SUCCESS')!=null &&AMOUNTDEDUCTIONSUCCESS.equalsIgnoreCase(amountDeductMap.get('SUCCESS'))) {
                        if(ticket.Id!=null) {
                            if(ticket.PRN_Number__c!=null) {
                                bookStatusMap.put(success, 'Succesfully ticket booked with PRN Number - ' + ticket.PRN_Number__c);
                            } else {
                                bookStatusMap.put(success, 'Successfuly Booked');
                            }
                        } else {
                            bookStatusMap.put(error, 'Please try after some time');
                        }
                    } else if(amountDeductMap.get('ERROR')!=null){
                        bookStatusMap.put(error, amountDeductMap.get('ERROR'));
                    }
                } else {
                    bookStatusMap.put(error, SEATNOTAVAILABLE);
                }
                
            } else {
                bookStatusMap.put(error, 'Please refresh the page');
            }
        } catch(Exception ex) {
            bookStatusMap.put(error, 'Something went wrong');
            System.debug('Exception in MetroSchedule' + ex.getLineNumber() + ex.getCause());
        }
        System.debug('before return booking stat' + bookStatusMap);
        return bookStatusMap;
    }
    
    private static boolean updateSeatAvailability(String metroSlot, String action, integer seatCnt) {
        System.debug('&&' + metroSlot);
        System.debug('&&' + action);
        System.debug('&&' + seatCnt);
        System.debug('updating seat cnt');
        boolean seatUpdated = false;
        try {
            if(!String.isEmpty(metroSlot) && !String.isEmpty(action) && seatCnt!=null && seatCnt>0) {
                MetroSlot__c metSlot = [select id, VacantSeats__c from MetroSlot__c where id=:metroSlot];
                if(metSlot.VacantSeats__c - seatCnt > 0) {
                    metSlot.VacantSeats__c = metSlot.VacantSeats__c - seatCnt;
                    update metSlot;
                    seatUpdated = true;
                } else {
                    seatUpdated = false;
                }
            } else {
                seatUpdated = false;
            }
        }catch(Exception ex) {
            seatUpdated = false;
            System.debug('Exception in Metro schedule' + ex.getCause() + ex.getLineNumber());
        }
        System.debug('seatUpdated return' + seatUpdated);
        return seatUpdated;
    }	
    
    
    private static integer getNumberofStatTravelled(String source, String destination) {
        System.debug('&&' + source);
        System.debug('&&' + destination);        
        integer sourceOrder = 0, destOrder = 0;
        try {
            if(!String.isEmpty(source) && !String.isEmpty(destination)) {
                List<Station__c> stationData  = [select id, Name, Station_Order__c, Metro_Station_Name__c from 
                                                 Station__c where (Metro_Station_Name__c =:source or
                                                                   Metro_Station_Name__c =:destination)];
                System.debug('stationData->' + stationData);
                for(Station__c stationObj : stationData) {
                    if(source.equalsIgnoreCase(stationObj.Metro_Station_Name__c)) {
                        sourceOrder = Integer.valueOf(stationObj.Station_Order__c);
                    } else if(destination.equalsIgnoreCase(stationObj.Metro_Station_Name__c)) {
						destOrder = Integer.valueOf(stationObj.Station_Order__c);
                    }
                }
                System.debug('return order' + (destOrder - sourceOrder));
                return destOrder - sourceOrder;
            }
            System.debug('return order' + (destOrder - sourceOrder));
            return destOrder - sourceOrder;
            
        } catch(Exception ex) {
            System.debug('Exception in Metro schedule' + ex.getCause() + ex.getLineNumber());
        }
        System.debug('return order' + (destOrder - sourceOrder));
        return destOrder - sourceOrder;
    }
    
    public static Map<String, String> updateCustomerWallet(String contactId, decimal fare) {
        Map<String, String> returnMap = new Map<String, String>();
        System.debug('contactId' + contactId);
        System.debug('fare' + fare);
        MetroWallet__c metroWallet;
        try {
            if(!String.isEmpty(contactId) && fare>0) {
                metroWallet = [select id, Contact__r.FirstName, WalletBalance__c from MetroWallet__c
                                              where Contact__c=:contactId order by WalletBalance__c DESC limit 1];
                System.debug('metroWallet->' + metroWallet);
                if(metroWallet!=null) {
                    System.debug('metroWallet->' + metroWallet);
                    if((metroWallet.WalletBalance__c - fare )> 0) {
                        metroWallet.WalletBalance__c = (metroWallet.WalletBalance__c - fare);   
                        update metroWallet;
                        System.debug('after update metroWallet->' + metroWallet);
                        returnMap.put(success, AMOUNTDEDUCTIONSUCCESS);
                    } else {
                        returnMap.put(error, 'Insuffcient Balance' + metroWallet + 'and balance=' + metroWallet.WalletBalance__c);
                    }
                } else {
                    returnMap.put(error, 'In outer else  metrowallet =' + metroWallet + 'and balance=' + metroWallet.WalletBalance__c);
                }
            } else {
                returnMap.put(error, 'Could Not deduct Amount');
            }
            
        } catch(Exception ex) {
            returnMap.put(error, 'Issues while deducting amount');
            System.debug('Exception in Metro schedule' + ex.getCause() + ex.getLineNumber());
        }
        System.debug('amount returnMap->' + returnMap);
        return returnMap;
    }
    
}