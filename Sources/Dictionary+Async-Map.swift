import Foundation



public extension Dictionary {
	
	func asyncMapValues<T>(_ transform: (Value) async throws -> T) async rethrows -> [Key: T] {
		var ret = [Key: T]()
		
		for (key, value) in self {
			try await ret[key] = transform(value)
		}
		
		return ret
	}
	
	func concurrentMapValues<T>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Value) async -> T) async -> [Key: T] {
		return await withTaskGroup(of: (key: Key, value: T).self) { group in
			for (key, element) in self {
				group.addTask(priority: priority) {
					return await (key, transform(element))
				}
			}
			
			var res = [Key: T]()
			while let next = await group.next() {
				assert(res[next.key] == nil)
				res[next.key] = next.value
			}
			return res
		}
	}
	
	func concurrentMapValues<T>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Value) async throws -> T) async throws -> [Key: T] {
		return try await withThrowingTaskGroup(of: (key: Key, value: T).self) { group in
			for (key, element) in self {
				group.addTask(priority: priority) {
					return try await (key, transform(element))
				}
			}
			
			var res = [Key: T]()
			while let next = try await group.next() {
				assert(res[next.key] == nil)
				res[next.key] = next.value
			}
			return res
		}
	}
	
}
