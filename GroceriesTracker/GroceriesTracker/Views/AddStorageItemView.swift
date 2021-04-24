//
//  AddStorageItemView.swift
//  GroceriesTracker
//
//  Created by Sophia on 3/20/21.
//

import Foundation
import SwiftUI
import Combine

// TODO: ADD DISMISS
struct AddStorageItemView: View {
  @Binding var fridge:[BoughtItem]
  @Binding var isPresented: Bool
  
  @State private var name: String = ""
  @State private var imageName: String = ""
  @State private var onShoppingList: Bool = true
  @State private var boughtItem: Bool = false
  @State private var daysExpireTime: Int = 0
  @State private var weeksExpireTime: Int = 0
  @State private var monthsExpireTime: Int = 0
  @State private var yearsExpireTime: Int = 0
  @State private var storageLocation: StorageLocation = .Fridge
  @State private var quantity: String = "0"
  @State private var qtyExpire: String = "0"
  
  @State private var itemSubmitted: Bool = false
  
  var storageList: [StorageLocation] = [.Fridge, .Pantry, .Freezer]
  
  @State private var storage = ""
  @State private var timeDescriptor = ""
  
  var body: some View {
    if !itemSubmitted {
      ZStack {
        //RadialGradient(gradient: Gradient(colors: [.orange, .red]), center: .center, startRadius: 100, endRadius: 470)
        LinearGradient(gradient: Gradient(colors: [.blue, .white, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
        //AngularGradient(gradient: Gradient(colors: [.green, .blue, .black, .green, .blue, .black, .green]), center: .center)
        VStack {
          Text("Add Item").font(.system(size: 30, design: .serif)).fontWeight(.bold)
          HStack {
            VStack(alignment: .leading) {
              Text("Item Name: ").frame(maxHeight: .infinity).padding(.bottom, 4)
              Text("Quantity: ").frame(maxHeight: .infinity).padding(.bottom, 4)
              Text("Stored In: ").frame(maxHeight: .infinity).padding(.bottom, 4)
              Text("Expires In: ").frame(maxHeight: .infinity).padding(.bottom, 4)
              
            }
            VStack(alignment: .leading) {
              HStack {
                Spacer()
                TextField("Item Name", text: $name)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer(minLength: 25)
              }
              HStack {
                // TODO: Use picker for quantity
                Spacer()
                TextField("Quantity", text: $quantity)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .keyboardType(.numberPad)
                  .onReceive(Just(quantity)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.quantity = filtered
                        }
                }
                Spacer(minLength: 25)
              }
              HStack {
                Menu {
                  Button {
                    storageLocation = .Fridge
                    storage = "Fridge"
                  } label: {
                    Text("Fridge")
                    //Image(systemName: "arrow.down.right.circle")
                  }
                  Button {
                    storageLocation = .Freezer
                    storage = "Freezer"
                  } label: {
                    Text("Freezer")
                    //Image(systemName: "arrow.up.and.down.circle")
                  }
                  Button {
                    storageLocation = .Pantry
                    storage = "Pantry"
                  } label: {
                    Text("Pantry")
                    //Image(systemName: "arrow.up.and.down.circle")
                  }
                } label: {
                  HStack {
                    Spacer()
                    Image(systemName: "plus.circle")
                    Text(storage)
                  }
                }
                Spacer(minLength: 25)
              }
              HStack {
                // TODO: Use picker for expiration times
                Spacer()
                TextField("Qty", text: $qtyExpire)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .keyboardType(.numberPad)
                  .onReceive(Just(quantity)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.quantity = filtered
                        }
                }
                Menu {
                  Button {
                    weeksExpireTime = 0
                    monthsExpireTime = 0
                    yearsExpireTime = 0
                    daysExpireTime = Int(qtyExpire) ?? 0
                    if daysExpireTime == 1 {
                      timeDescriptor = "Day"
                    } else { timeDescriptor = "Days" }
                  } label: {
                    Text("Days")
                  }
                  Button {
                    daysExpireTime = 0
                    monthsExpireTime = 0
                    yearsExpireTime = 0
                    weeksExpireTime = Int(qtyExpire) ?? 0
                    if weeksExpireTime == 1 {
                      timeDescriptor = "Week"
                    } else { timeDescriptor = "Weeks" }
                  } label: {
                    Text("Weeks")
                  }
                  Button {
                    daysExpireTime = 0
                    weeksExpireTime = 0
                    yearsExpireTime = 0
                    monthsExpireTime = Int(qtyExpire) ?? 0
                    if monthsExpireTime == 1 {
                      timeDescriptor = "Month"
                    } else { timeDescriptor = "Months" }
                  } label: {
                    Text("Months")
                  }
                  Button {
                    daysExpireTime = 0
                    weeksExpireTime = 0
                    monthsExpireTime = 0
                    yearsExpireTime = Int(qtyExpire) ?? 0
                    if yearsExpireTime == 1 {
                      timeDescriptor = "Year"
                    } else { timeDescriptor = "Years" }
                  } label: {
                    Text("Years")
                  }
                } label: {
                  HStack {
                    Image(systemName: "plus.circle")
                    Text(timeDescriptor)
                  }
                }
                Spacer(minLength: 25)
              }
              HStack {
                // TODO: Upload image somehow
              }
              
            }.padding(.leading)
            
          }.padding(.horizontal)
          .fixedSize(horizontal: false, vertical: true)
          VStack {
            //Spacer(minLength: 5)
            Button(action: {
              // submit action
              self.itemSubmitted.toggle()
              var groc = GroceryItem(name: name, imageName: "", onShoppingList: false, daysExpireTime: daysExpireTime, weeksExpireTime: weeksExpireTime, monthsExpireTime: monthsExpireTime, yearsExpireTime: yearsExpireTime, storageLocation: storageLocation, quantity: Int(quantity) ?? 0, expirationDate: nil) 
              groc.setExpirationDate()
              let bought = BoughtItem(groceryItem: groc)
              fridge.append(bought)
              isPresented = false
            }, label: {
              Text("Add")
            })
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Button("Cancel") {
              isPresented = false
            }
          }.padding(.vertical)
          .fixedSize(horizontal: false, vertical: true)
        }
      }.edgesIgnoringSafeArea(.all)
    } else {
      Text("Added!")
    }
  }
}

// TODO: ADD DISMISS
struct AddStorageItemCoreDataView: View {
  //@Binding var fridge:[BoughtItem]
  @Binding var isPresented: Bool
  
  @State private var name: String = ""
  @State private var imageName: String = ""
  @State private var onShoppingList: Bool = true
  @State private var boughtItem: Bool = false
  @State private var daysExpireTime: Int = 0
  @State private var weeksExpireTime: Int = 0
  @State private var monthsExpireTime: Int = 0
  @State private var yearsExpireTime: Int = 0
  @State private var storageLocation: StorageLocation = .Fridge
  @State private var quantity: String = "0"
  @State private var qtyExpire: String = "0"
  
  @State private var itemSubmitted: Bool = false
  
  var storageList: [StorageLocation] = [.Fridge, .Pantry, .Freezer]
  
  @State private var storage = ""
  @State private var timeDescriptor = ""
  
  var body: some View {
    if !itemSubmitted {
      ZStack {
        //RadialGradient(gradient: Gradient(colors: [.orange, .red]), center: .center, startRadius: 100, endRadius: 470)
        LinearGradient(gradient: Gradient(colors: [.blue, .white, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
        //AngularGradient(gradient: Gradient(colors: [.green, .blue, .black, .green, .blue, .black, .green]), center: .center)
        VStack {
          HStack {
            VStack{ Image("apple")
              .resizable()
              .aspectRatio(contentMode: .fit)
            }.frame(width: 30.0,height:30.0);
            VStack{ Image("avocado")
              .resizable()
              .aspectRatio(contentMode: .fit)
            }.frame(width: 30.0,height:30.0);
            VStack{ Image("carrot")
              .resizable()
              .aspectRatio(contentMode: .fit)
            }.frame(width: 30.0,height:30.0);
          }
          Text("Add Item").font(.system(size: 30, design: .serif)).fontWeight(.bold)
          HStack {
            VStack(alignment: .leading) {
              Text("Item Name: ").frame(maxHeight: .infinity).padding(.bottom, 4)
              Text("Quantity: ").frame(maxHeight: .infinity).padding(.bottom, 4)
              Text("Stored In: ").frame(maxHeight: .infinity).padding(.bottom, 4)
              Text("Expires In: ").frame(maxHeight: .infinity).padding(.bottom, 4)
              
            }
            VStack(alignment: .leading) {
              HStack {
                Spacer()
                TextField("Item Name", text: $name)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer(minLength: 25)
              }
              HStack {
                // TODO: Use picker for quantity
                Spacer()
                TextField("Quantity", text: $quantity)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .keyboardType(.numberPad)
                  .onReceive(Just(quantity)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.quantity = filtered
                        }
                }
                Spacer(minLength: 25)
              }
              HStack {
                Menu {
                  Button {
                    storageLocation = .Fridge
                    storage = "Fridge"
                  } label: {
                    Text("Fridge")
                    //Image(systemName: "arrow.down.right.circle")
                  }
                  Button {
                    storageLocation = .Freezer
                    storage = "Freezer"
                  } label: {
                    Text("Freezer")
                    //Image(systemName: "arrow.up.and.down.circle")
                  }
                  Button {
                    storageLocation = .Pantry
                    storage = "Pantry"
                  } label: {
                    Text("Pantry")
                    //Image(systemName: "arrow.up.and.down.circle")
                  }
                } label: {
                  HStack {
                    Spacer()
                    Image(systemName: "plus.circle")
                    Text(storage)
                  }
                }
                Spacer(minLength: 25)
              }
              HStack {
                // TODO: Use picker for expiration times
                Spacer()
                TextField("Qty", text: $qtyExpire)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .keyboardType(.numberPad)
                  .onReceive(Just(quantity)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.quantity = filtered
                        }
                }
                Menu {
                  Button {
                    weeksExpireTime = 0
                    monthsExpireTime = 0
                    yearsExpireTime = 0
                    daysExpireTime = Int(qtyExpire) ?? 0
                    if daysExpireTime == 1 {
                      timeDescriptor = "Day"
                    } else { timeDescriptor = "Days" }
                  } label: {
                    Text("Days")
                  }
                  Button {
                    daysExpireTime = 0
                    monthsExpireTime = 0
                    yearsExpireTime = 0
                    weeksExpireTime = Int(qtyExpire) ?? 0
                    if weeksExpireTime == 1 {
                      timeDescriptor = "Week"
                    } else { timeDescriptor = "Weeks" }
                  } label: {
                    Text("Weeks")
                  }
                  Button {
                    daysExpireTime = 0
                    weeksExpireTime = 0
                    yearsExpireTime = 0
                    monthsExpireTime = Int(qtyExpire) ?? 0
                    if monthsExpireTime == 1 {
                      timeDescriptor = "Month"
                    } else { timeDescriptor = "Months" }
                  } label: {
                    Text("Months")
                  }
                  Button {
                    daysExpireTime = 0
                    weeksExpireTime = 0
                    monthsExpireTime = 0
                    yearsExpireTime = Int(qtyExpire) ?? 0
                    if yearsExpireTime == 1 {
                      timeDescriptor = "Year"
                    } else { timeDescriptor = "Years" }
                  } label: {
                    Text("Years")
                  }
                } label: {
                  HStack {
                    Image(systemName: "plus.circle")
                    Text(timeDescriptor)
                  }
                }
                Spacer(minLength: 25)
              }
              HStack {
                // TODO: Upload image somehow
              }
              
            }.padding(.leading)
            
          }.padding(.horizontal)
          .fixedSize(horizontal: false, vertical: true)
          VStack {
            //Spacer(minLength: 5)
            Button(action: {
              // submit action
              var groc = GroceryItem(name: name.lowercased(), imageName: name.lowercased().replacingOccurrences(of: "\\s", with: "", options: .regularExpression), onShoppingList: false, daysExpireTime: daysExpireTime, weeksExpireTime: weeksExpireTime, monthsExpireTime: monthsExpireTime, yearsExpireTime: yearsExpireTime, storageLocation: storageLocation, quantity: Int(quantity) ?? 0, expirationDate: nil)
              groc.setExpirationDate()
              groc.convertToManagedObject()
              
              do {
                try MyGroceryTrackerCoreDataModel.context.save()
              } catch {
                print("Error saving item to core data \(error)")
              }
              
              //let bought = BoughtItem(groceryItem: groc)
              //fridge.append(bought)
              self.itemSubmitted.toggle()
              isPresented = false
            }, label: {
              Text("Add")
            })
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Button("Cancel") {
              isPresented = false
            }
          }.padding(.vertical)
          .fixedSize(horizontal: false, vertical: true)
        }
      }.edgesIgnoringSafeArea(.all)
    } else {
      Text("Added!")
    }
  }
}
