import Foundation

class ArrayToDataTransformer: ValueTransformer {
    // This method tells Core Data which class type the transformer returns (NSData)
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    // This method performs the actual transformation from an array to NSData
    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [Any] else { return nil }
        
        // Convert the array to Data using JSONSerialization
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: [])
            return data as NSData
        } catch {
            print("Error serializing array to data: \(error)")
            return nil
        }
    }
    
    // This method is used to reverse the transformation (optional for Core Data, but useful for undoing the transformation)
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        
        // Deserialize the NSData back into an array using JSONSerialization
        do {
            if let array = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [Any] {
                return array
            }
        } catch {
            print("Error deserializing data to array: \(error)")
        }
        return nil
    }
}
