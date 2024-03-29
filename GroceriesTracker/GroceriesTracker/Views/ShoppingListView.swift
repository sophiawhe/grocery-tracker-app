//
//  ShoppingListView.swift
//  GroceriesTracker
//
//  Created by Sophia on 2/28/21.
//

import Foundation
import SwiftUI
import Combine


// Shows grocery items (row view)
struct GroceryItemRowView: View {
  
  var item: GroceryItem
  
  var body: some View {
    HStack {
      VStack{ Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }.frame(width: 20.0,height:20.0);
      Text(item.name).font(.system(size: 25, design: .serif))
      Spacer()
      Text(String(item.quantity)).font(.system(size: 15, design: .serif))
    }
  }
  
}

// Shows grocery items (row view) - core data
struct GroceryItemCoreDataRowView: View {
  
  var item: GroceryItem
  var dataItem: GroceryItemEntity
  
  var body: some View {
    HStack {
      VStack{ Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }.frame(width: 20.0,height:20.0);
      Text(item.name).font(.system(size: 25, design: .serif))
      Spacer()
      Text(String(dataItem.quantity)).font(.system(size: 15, design: .serif))
      // commented out +/- buttons -> implemented in
      // grocery item view instead
      /*HStack{
        Button(action: {
            print("Edit button was tapped")
        }) {
            Image(systemName: "plus.circle")
        }
        Text(String(item.quantity))//.font(.system(size: 15, design: .serif))
        Button(action: {
            print("Edit button was tapped")
        }) {
            Image(systemName: "minus.circle")
        }
      }*/
    }
  }
  
}


// shows shopping list contents - core data
struct CoreDataShoppingListView: View {
  
  @Binding var fridge: [BoughtItem]
  @Binding var freezer: [BoughtItem]
  @Binding var pantry: [BoughtItem]
  
  
  init(fridge: Binding<[BoughtItem]>, freezer: Binding<[BoughtItem]>, pantry: Binding<[BoughtItem]>) {
    self._fridge = fridge
    self._freezer = freezer
    self._pantry = pantry
    UINavigationBar.appearance().barTintColor = UIColor(red: 144 / 255, green: 238 / 255, blue: 144 / 255, alpha: 1)
  }
  
  @Environment(\.managedObjectContext) var context
  @FetchRequest(
    entity: GroceryItemEntity.entity(),
    sortDescriptors: [
      NSSortDescriptor(keyPath: \GroceryItemEntity.name, ascending: true),],
    predicate:  NSPredicate(format: "onShoppingList == true")
  ) var shoppingList: FetchedResults<GroceryItemEntity>
  @State private var name = ""
  @State private var isAddSheetShowing = false
  @State private var itemsToEdit = Set<String>()
  @State var isEditMode: EditMode = .active
  
  @State var isEditing = false
  @State var selection = Set<String>()

  var body: some View {
    NavigationView {
      ZStack {
        VStack {
          NotificationView()
          List(shoppingList, id: \.name!, selection: $itemsToEdit) { item in
            let grocItem = GroceryItem(groceryItemEntity: MyGroceryTrackerCoreDataModel.getGroceryItemWith(name: item.name!)!)
            NavigationLink(destination: GroceryItemCoreDataView(item: grocItem, dataItem: item), label: {
              GroceryItemCoreDataRowView(item: grocItem, dataItem: item)
            })
            
          }
          .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
          .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                      Spacer()
                      Text("Shopping List").font(.system(size: 25, design: .serif))
                      Spacer()
                      Spacer()
                      
                    }.foregroundColor(.black)
                }
            }
          //.navigationBarColor(backgroundColor: .green, titleColor: .white)
          .navigationBarItems(leading:
                                Button(isEditing ? "Check Off" : "Edit") {
                                  if !isEditing {
                                    self.isEditing.toggle()
                                  }else {
                                    itemsToEdit.forEach(){ item in
                                      print(itemsToEdit)
                                      // TODO CHANGE THIS FOR CORE DATA
                                      let grocIndex = shoppingList.firstIndex(where: { $0.name! ==  item})
                                      let groc = shoppingList[grocIndex!]
                                      print(groc)
                                      var grocItem = GroceryItem(groceryItemEntity: MyGroceryTrackerCoreDataModel.getGroceryItemWith(name: groc.name!)!)
                                      grocItem.setExpirationDate()
                                      
                                      groc.expirationDate = grocItem.expirationDate!;
                                      print("groc.expirationDate")
                                      print(groc.expirationDate!)
                                      
                                      // DEMO
                                      var notifyDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: grocItem.expirationDate!)
                                      notifyDate.minute! += 1
                                      
                                      // REAL
                                      //notifyDate.hour = 10
                                      //notifyDate.minute = 0
                                      NotificationView().setupAndFireNotification(date: notifyDate, item: groc.name!)
                                      
                                      groc.onShoppingList = false

                                      do {
                                        try MyGroceryTrackerCoreDataModel.context.save()
                                      } catch {
                                        print("Error saving item to core data \(error)")
                                      }
                                      let itemIndex = itemsToEdit.firstIndex(of: item)
                                      itemsToEdit.remove(at:itemIndex!)
                                    
                                    }
                                    self.isEditing.toggle()

                                  }
                                },
                              trailing: Button(isEditing ? "Delete" : "Add") {
                                if !isEditing {
                                  self.isAddSheetShowing.toggle()
                                }else {
                                  itemsToEdit.forEach(){ item in
                                    print(itemsToEdit)

                                    let grocIndex = shoppingList.firstIndex(where: { $0.name! ==  item})
                                    let groc = shoppingList[grocIndex!]
                            
                                    context.delete(groc)
                                    let itemIndex = itemsToEdit.firstIndex(of: item)
                                    itemsToEdit.remove(at:itemIndex!)

                                  }
                                  self.isEditing.toggle()

                                }
                              }).sheet(isPresented: self.$isAddSheetShowing, content: {
                                AddShoppingListItemCoreDataView(isPresented: $isAddSheetShowing, name: $name)
                              })
              
        }
        
      }.edgesIgnoringSafeArea(.all)
    }//.navigationViewStyle(StackNavigationViewStyle())
  }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

struct NavigationBarModifier: ViewModifier {

    var backgroundColor: UIColor?
    var titleColor: UIColor?

    init(backgroundColor: UIColor?, titleColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .white]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {

    func navigationBarColor(backgroundColor: UIColor?, titleColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }

}

extension Color {
    static let teal = Color(red: 49 / 255, green: 163 / 255, blue: 159 / 255)
    static let darkPink = Color(red: 208 / 255, green: 45 / 255, blue: 208 / 255)
}


// shows shopping list contents - non core data
struct ShoppingListView: View {
  @Binding var shoppingList: [GroceryItem]
  
  @Binding var fridge: [BoughtItem]
  @Binding var freezer: [BoughtItem]
  @Binding var pantry: [BoughtItem]
  
  @State private var isAddSheetShowing = false
  @State private var itemsToAdd = Set<String>()
  @State var isEditMode: EditMode = .active
  
  @State var isEditing = false
  @State var selection = Set<String>()
  
  var dataModel = testModel
  
  var body: some View {
    NavigationView {
      ZStack {
        RadialGradient(gradient: Gradient(colors: [.orange, .red]), center: .center, startRadius: 100, endRadius: 470)
        VStack {
          List(shoppingList, id: \.name, selection: $itemsToAdd) { item in
            NavigationLink(destination: GroceryItemView(item: item), label: {
              GroceryItemRowView(item: item)
            })
          }
          .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
          .navigationBarTitleDisplayMode(.inline)
          //.navigationTitle("Shopping List")
            //.background(NavigationConfigurator { nc in
            //  nc.navigationBar.barTintColor = .blue
            //  nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
            //})
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                      Spacer()
                      Text("Shopping List").font(.system(size: 25, design: .serif))
                      Spacer()
                      Spacer()
                      
                    }
                }
            }
          .navigationBarItems(leading:
                                Button(isEditing ? "Check Off" : "Edit") {
                                  if !isEditing {
                                    self.isEditing.toggle()
                                  }else {
                                    itemsToAdd.forEach(){ item in
                                      print(itemsToAdd)

                                      let grocIndex = shoppingList.firstIndex(where: { $0.name ==  item})
                                      let groc = shoppingList[grocIndex!]
                                      let bought = BoughtItem(groceryItem: groc)
                                      if groc.storageLocation == .Fridge {
                                        fridge.append(bought)
                                      } else if groc.storageLocation == .Freezer {
                                        freezer.append(bought)
                                      } else if groc.storageLocation == .Pantry {
                                        pantry.append(bought)
                                      }
                              
                                      shoppingList.remove(at:grocIndex!)
                                      let itemIndex = itemsToAdd.firstIndex(of: item)
                                      itemsToAdd.remove(at:itemIndex!)
                                      
                                    }
                                    self.isEditing.toggle()
                                  }
                                },
                              trailing: Button(isEditing ? "Delete" : "Add") {
                                if !isEditing {
                                  self.isAddSheetShowing.toggle()
                                }else {
                                  itemsToAdd.forEach(){ item in
                                    print(itemsToAdd)

                                    let grocIndex = shoppingList.firstIndex(where: { $0.name ==  item})
                                    let groc = shoppingList[grocIndex!]
                                    let bought = BoughtItem(groceryItem: groc)
                                    if groc.storageLocation == .Fridge {
                                      fridge.append(bought)
                                    } else if groc.storageLocation == .Freezer {
                                      freezer.append(bought)
                                    } else if groc.storageLocation == .Pantry {
                                      pantry.append(bought)
                                    }
                            
                                    shoppingList.remove(at:grocIndex!)
                                    let itemIndex = itemsToAdd.firstIndex(of: item)
                                    itemsToAdd.remove(at:itemIndex!)
                                    
                                  }
                                  self.isEditing.toggle()
                                }
                              }).sheet(isPresented: self.$isAddSheetShowing, content: {
                                AddShoppingListItemView(shoppingList: $shoppingList)
                              })
        }
        
      }.edgesIgnoringSafeArea(.all)
    }
  }
}

// not needed - experimenting
struct CounterList: View {
  @State var counters = ["a","b","c"]
  var body: some View {
    NavigationView {
      List {
        ForEach(counters, id: \.self) { counter in
          NavigationLink(destination: Text(counter)) {
            CounterCell(counter: counter)
          }
        }
      }
      .buttonStyle(PlainButtonStyle())
      .listStyle(GroupedListStyle())
    }.navigationViewStyle(StackNavigationViewStyle())
  }
}

struct CounterCell: View {
  
  @State var counter: String
  @State var inc = 0
  
  var body: some View {
    HStack {
      Button(action: { self.inc += 1 }) {
        Text("plus")
      }
      Button(action: { self.inc -= 1 }) {
        Text("minus")
      }
      Text(" counter: \(counter) value: \(inc)")
    }
  }
}
