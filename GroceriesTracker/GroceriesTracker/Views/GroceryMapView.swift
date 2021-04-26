//
//  GroceryMapView.swift
//  GroceriesTracker
//
//  Created by Sophia on 4/22/21.
//  Followed tutorial at https://www.youtube.com/watch?v=WTzBKOe7MmU

import Foundation
import SwiftUI
import MapKit

// uses mapview, shows nearby grocery stores
// user can also search other types of locations
struct GroceryMapView: View {
  
  @ObservedObject var locationManager = LocationManager()
  @State private var landmarks: [Landmark] = []
  @State private var search: String = "Grocery Stores"
  @State private var tapped: Bool = false
  
  private func getNearByLandmarks() {
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = search
    
    let search = MKLocalSearch(request: request)
    search.start { (response, error) in
      if let response = response {
        
        let mapItems = response.mapItems
        self.landmarks = mapItems.map {
          Landmark(placemark: $0.placemark)
        }
        
      }
      
    }
    
  }
  
  func calculateOffset() -> CGFloat {
    
    if self.landmarks.count > 0 && !self.tapped {
      return UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height / 4
    }
    else if self.tapped {
      return 100
    } else {
      return UIScreen.main.bounds.size.height
    }
  }
  
  var body: some View {
    ZStack(alignment: .top) {
      
      MapView(landmarks: landmarks)
      
      HStack {
        TextField("Search", text: $search, onEditingChanged: { _ in })
        {
          self.getNearByLandmarks()
        }.textFieldStyle(RoundedBorderTextFieldStyle())
        
        Button("Search") {
          self.getNearByLandmarks()
        }
      
      }.padding()
      .offset(y: 44)
      
      PlaceListView(landmarks: self.landmarks) {
        // on tap
        self.tapped.toggle()
      }.animation(.spring())
      .offset(y: calculateOffset())
      
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    GroceryMapView()
  }
}
