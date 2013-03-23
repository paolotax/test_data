class NSManagedObject
  def self.entity
    @entity ||= NSEntityDescription.newEntityDescriptionWithName(name, attributes:@attributes, relationships:@relationships)
  end

  def self.objects
    # Use if you do not need any section in your table view
    @objects ||= NSFetchRequest.fetchObjectsForEntityForName(name, withSortKeys:@sortKeys, ascending:@sortOrders, inManagedObjectContext:Store.shared.context)
  end

  def self.controller
    # Use if you require sections in your table view
    @controller ||= NSFetchRequest.fetchObjectsForEntityForName(name, withSectionKey:@sectionKey, withSortKeys:@sortKeys, ascending:@sortOrders, withsearchKey:nil, withSearchString:nil, inManagedObjectContext:Store.shared.context)
  end
  
  def self.searchController(searchString)
    # Use if you have a search bar in your table view
    @searchController ||= NSFetchRequest.fetchObjectsForEntityForName(name, withSectionKey:@sectionKey, withSortKeys:@sortKeys, ascending:@sortOrders, withsearchKey:@searchKey, withSearchString:searchString, inManagedObjectContext:Store.shared.context)
  end

  def self.searchController(searchString, searchScope)
    # Use if you have a search bar in your table view
    @searchController ||= NSFetchRequest.fetchObjectsForEntityForName(name, withSectionKey:@sectionKey, withSortKeys:@sortKeys, ascending:@sortOrders, withsearchKey:@searchKey, withSearchString:searchString, withSearchScope:searchScope, inManagedObjectContext:Store.shared.context)
  end

  def save_to_backend
    puts "save to backend"
    
    if self.remote_id == 0  
      # // POST to create
      Store.shared.backend.postObject(self, path:nil, parameters:nil, 
                          success:lambda do |operation, result|
                                    puts "new id = #{self.remote_id}"
                                    puts Store.shared.stats
                                    Store.shared.persist
                                    puts "persist"
                                    puts Store.shared.stats                                    
                                    "appuntiListDidLoadBackend".post_notification
                                    "reload_appunti_collections".post_notification
                                    "clientiListDidLoadBackend".post_notification
                                  end, 
                          failure:lambda do |operation, error|
                                    puts self.remote_id 
                                  end)
    else
      Store.shared.backend.putObject(self, path:nil, parameters:nil, 
                          success:lambda do |operation, result|
                                    puts "updated = #{self.remote_id}"
                                    puts Store.shared.stats
                                    Store.shared.persist  
                                    puts "persist"
                                    puts Store.shared.stats        
                                    "appuntiListDidLoadBackend".post_notification
                                    "reload_appunti_collections".post_notification
                                    "clientiListDidLoadBackend".post_notification   
                                  end, 
                          failure:lambda do |operation, error|
                                    #Store.shared.persist
                                  end)

    # elsif self.isUpdated == true
    #   Store.shared.backend.deleteObject(self, path:nil, parameters:nil, 
    #                       success:lambda do |operation, result|
    #                                 puts self.remote_id         
    #                               end, 
    #                       failure:lambda do |operation, error|
    #                                 #Store.shared.persist
    #                               end)

    end
  end



  
  def self.reset
    @objects = @controller = @searchController = nil
  end

  def self.add
    yield obj = NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext:Store.shared.context)
    Store.shared.save
    obj
  end
  
  def update
    Store.shared.save
  end

  def remove
    Store.shared.context.deleteObject(self)
    Store.shared.save
  end
  
  def self.sections
    @sections
  end
  
  def self.numTextSections
    @sections.flatten.select{|x| x == :text or x == :longtext}.size
  end
  
  def managedObjectClass
    # Core data objects are not instances of NSManagedObjects, although they behave the same
    # Allow access to the real class
    NSClassFromString(self.entity.managedObjectClassName)
  end
end