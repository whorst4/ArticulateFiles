public with sharing class Order_CreateController {

    @AuraEnabled
    public static Id addProducts(Id orderId) {
        Order newOrder = [SELECT Id, OpportunityId, Pricebook2Id FROM Order WHERE Id = :orderId LIMIT 1];
        Opportunity opp = [SELECT Id, Contact__c, Contact__r.Academic_User__c FROM Opportunity 
                           WHERE Id = :newOrder.OpportunityId LIMIT 1];
        
       	Product2 productToAdd;
        PricebookEntry productPrice;
        if (opp.Contact__r.Academic_User__c) { 
        	productToAdd = [SELECT Id, Name, ProductCode FROM Product2 
                            WHERE ProductCode = '0002' AND IsActive = true LIMIT 1];
            productPrice = [SELECT Id, UnitPrice, Pricebook2Id FROM PricebookEntry 
                            WHERE IsActive = true AND Product2Id = :productToAdd.Id LIMIT 1];
    	}
        else {
            productToAdd = productToAdd = [SELECT Id, Name, ProductCode FROM Product2 
                            WHERE ProductCode = '0001' AND IsActive = true LIMIT 1];
            productPrice = [SELECT Id, UnitPrice, Pricebook2Id FROM PricebookEntry 
                            WHERE IsActive = true AND Product2Id = :productToAdd.Id LIMIT 1];
		}
        
        //add pricebook to new item
        newOrder.Pricebook2Id = productPrice.Pricebook2Id;
        update newOrder;
        
        //system.debug('creating new order item');
        
        OrderItem newOrderItem = new OrderItem(
            						OrderId = orderId,
                                    UnitPrice = productPrice.UnitPrice,
                                    Quantity = 1,
             						PricebookEntryId = productPrice.Id
                                   );
        //system.debug('inserting new order item');
        insert newOrderItem;
        
        //system.debug('returning');
        return newOrderItem.Id;
    }
    
    @AuraEnabled
    public static void UpdateItems(Id orderId, Id orderItemId, boolean addPC) {
        system.debug('addPC: ' + addPC);
        if (addPC != NULL) {
            if (addPC) {
                system.debug('inserting new order item');
                OrderItem currOrderItem = [SELECT Id, Quantity FROM OrderItem 
                                           WHERE Id = :orderItemId LIMIT 1];
                Product2 productToAdd;
                PricebookEntry productPrice;
                productToAdd = [SELECT Id, Name, ProductCode FROM Product2 
                                WHERE ProductCode = '0003' AND IsActive = true LIMIT 1];
                productPrice = [SELECT Id, UnitPrice, Pricebook2Id FROM PricebookEntry 
                                WHERE IsActive = true AND Product2Id = :productToAdd.Id LIMIT 1];
                
                Decimal unitPrice = 0;
                if (currOrderItem.Quantity < 5) {
                    unitPrice = productPrice.UnitPrice;
                }
                OrderItem newOrderItem = new OrderItem(
                    OrderId = orderId,
                    UnitPrice = unitPrice,
                    Quantity = 1,
                    PricebookEntryId = productPrice.Id
                );
                
                system.debug('inserting new order item');
                insert newOrderItem;
            }
        }
        //sendEmail(orderId, orderItemId);
        return;
    }
    
    public static void sendEmail(Id orderId, Id orderItemId) {
        Order currOrder = [SELECT Id, TotalAmount, Name, AccountId, Account.Name, OpportunityId, Opportunity.Contact__c, 
                           Opportunity.Contact__r.MailingAddress, Opportunity.Contact__r.FirstName,
                           Opportunity.Contact__r.LastName, Opportunity.Contact__r.Phone, Opportunity.Contact__r.Email
                           FROM Order 
                           WHERE Id = :orderId LIMIT 1];
        List<OrderItem> currOrderItems = [SELECT Id, Quantity, UnitPrice, TotalPrice, Product2Id, Product2.Name 
                                          FROM OrderItem 
                                          WHERE Id = :orderItemId];
        
        system.debug('sending email');
        Integer numProds = currOrderItems.size();
        
        String currUserEmail = UserInfo.getUserEmail();
        
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] {currOrder.Opportunity.Contact__r.Email}; 
        String[] ccAddresses = new String[] {currUserEmail};             
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        
        mail.setSenderDisplayName('Test Dev Environment');
        mail.setSubject('New Order Created');
        mail.setBccSender(false);
        mail.setUseSignature(false);
          
        if (numProds > 1) {
            mail.setHtmlBody('Your Order has been created.<p>' 
                             + '<b>Contact</b>'
                             + '<br>Name: ' + currOrder.Opportunity.Contact__r.FirstName + ' ' + currOrder.Opportunity.Contact__r.LastName
                             + '<br>Account: ' +  currOrder.Account.Name 
                             + '<br>Mailing Address: ' + currOrder.Opportunity.Contact__r.MailingAddress
                             + '<br>Email: ' + currOrder.Opportunity.Contact__r.Email
                             + '<br>Phone: ' + currOrder.Opportunity.Contact__r.Phone
                             + '<br><b>Order Breakdown</b>'
                             + '<br>Product 1: ' + currOrderItems[0].Product2.Name
                             + '<br>Ordered Quantity: ' + currOrderItems[0].Quantity
                             + '<br>UnitPrice: ' + currOrderItems[0].UnitPrice
                             + '<br>Line Item Total: ' + currOrderItems[0].TotalPrice
                             + '<br><br />Product 2: ' + currOrderItems[1].Product2.Name
                             + '<br>Ordered Quantity: ' + currOrderItems[1].Quantity
                             + '<br>UnitPrice: ' + currOrderItems[1].UnitPrice
                             + '<br>Line Item Total: ' + currOrderItems[1].TotalPrice
                             + '<br><b>Total Amount</b>: ' + currOrder.TotalAmount
                             + '</p>');
            
        }
        else {
            mail.setHtmlBody('Your Order has been created.<p>' 
                             + '<b>Contact</b>'
                             + '<br>Name: ' + currOrder.Opportunity.Contact__r.FirstName + ' ' + currOrder.Opportunity.Contact__r.LastName
                             + '<br>Account: ' +  currOrder.Account.Name 
                             + '<br>Mailing Address: ' + currOrder.Opportunity.Contact__r.MailingAddress
                             + '<br>Email: ' + currOrder.Opportunity.Contact__r.Email
                             + '<br>Phone: ' + currOrder.Opportunity.Contact__r.Phone
                             + '<br><b>Order Breakdown</b>'
                             + '<br>Product: ' + currOrderItems[0].Product2.Name
                             + '<br>Ordered Quantity: ' + currOrderItems[0].Quantity
                             + '<br>UnitPrice: ' + currOrderItems[0].UnitPrice
                             + '<br>Line Item Total: ' + currOrderItems[0].TotalPrice
                             + '<br><b>Total Amount</b>: ' + currOrder.TotalAmount
                             + '</p>');
        }
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}