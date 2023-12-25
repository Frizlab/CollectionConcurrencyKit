import Foundation



public extension Sequence {
	
	/**
	 Transform the sequence into an array of new values using an async closure.
	 
	 The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one.
	 If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.
	 
	 - parameter transform: The transform to run on each element.
	 - returns: The transformed values as an array.
	 The order of the transformed values will match the original sequence.
	 - throws: Rethrows any error thrown by the passed closure. */
	func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
		var values = [T]()
		
		for element in self {
			try await values.append(transform(element))
		}
		
		return values
	}
	
	/**
	 Transform the sequence into an array of new values using an async closure.
	 
	 The closure calls will be performed concurrently, but the call to this function won’t return until all of the closure calls have completed.
	 
	 - parameter priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls.
	 The default is `nil` (meaning that the system picks a priority).
	 - parameter transform: The transform to run on each element.
	 - returns: The transformed values as an array.
	 The order of the transformed values will match the original sequence. */
	func concurrentMap<T>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async -> T) async -> [T] {
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
			return res as! [T]
		}
	}
	
	/**
	 Transform the sequence into an array of new values using an async closure.
	 
	 The closure calls will be performed concurrently, but the call to this function won’t return until all of the closure calls have completed.
	 If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.
	 
	 - parameter priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls.
	 The default is `nil` (meaning that the system picks a priority).
	 - parameter transform: The transform to run on each element.
	 - returns: The transformed values as an array.
	 The order of the transformed values will match the original sequence.
	 - throws: Rethrows any error thrown by the passed closure. */
	func concurrentMap<T>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async throws -> T) async throws -> [T] {
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
			return res as! [T]
		}
	}
	
}
