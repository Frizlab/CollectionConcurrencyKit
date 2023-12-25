import Foundation



public extension Sequence {
	
	/**
	 Transform the sequence into an array of new values using an async closure that returns sequences.
	 The returned sequences will be flattened into the array returned from this function.
	 
	 The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one.
	 If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.
	 
	 - parameter transform: The transform to run on each element.
	 - returns: The transformed values as an array.
	 The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array.
	 - throws: Rethrows any error thrown by the passed closure. */
	func asyncFlatMap<T: Sequence>(_ transform: (Element) async throws -> T) async rethrows -> [T.Element] {
		var values = [T.Element]()
		
		for element in self {
			try await values.append(contentsOf: transform(element))
		}
		
		return values
	}
	
	/**
	 Transform the sequence into an array of new values using an async closure that returns sequences.
	 The returned sequences will be flattened into the array returned from this function.
	 
	 The closure calls will be performed concurrently, but the call to this function won’t return until all of the closure calls have completed.
	 
	 - parameter priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls.
	 The default is `nil` (meaning that the system picks a priority).
	 - parameter transform: The transform to run on each element.
	 - returns: The transformed values as an array.
	 The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array. */
	func concurrentFlatMap<T: Sequence>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async -> T) async -> [T.Element] {
		return await withTaskGroup(of: (offset: Int, value: T).self) { group in
			var c = 0
			for element in self {
				let idx = c
				c += 1
				group.addTask(priority: priority) {
					return await (idx, transform(element))
				}
			}
			
			var res = Array<T?>(repeating: nil, count: c)
			while let next = await group.next() {
				res[next.offset] = next.value
			}
			return (res as! [T]).flatMap{ $0 }
		}
	}
	
	/**
	 Transform the sequence into an array of new values using an async closure that returns sequences.
	 The returned sequences will be flattened into the array returned from this function.
	 
	 The closure calls will be performed concurrently, but the call to this function won’t return until all of the closure calls have completed.
	 If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.
	 
	 - parameter priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls.
	 The default is `nil` (meaning that the system picks a priority).
	 - parameter transform: The transform to run on each element.
	 - returns: The transformed values as an array.
	 The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array.
	 - throws: Rethrows any error thrown by the passed closure. */
	func concurrentFlatMap<T: Sequence>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async throws -> T) async throws -> [T.Element] {
		return try await withThrowingTaskGroup(of: (offset: Int, value: T).self) { group in
			var c = 0
			for element in self {
				let idx = c
				c += 1
				group.addTask(priority: priority) {
					return try await (idx, transform(element))
				}
			}
			
			var res = Array<T?>(repeating: nil, count: c)
			while let next = try await group.next() {
				res[next.offset] = next.value
			}
			return (res as! [T]).flatMap{ $0 }
		}
	}
	
}
