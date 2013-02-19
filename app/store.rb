class Store
  
  DB = 'Libri.sqlite'
  ManagedObjectClasses = [Libro, Cliente, Appunto, Riga]
  
  #BASE_URL = "http://youpropa.com"
  BASE_URL = "http://localhost:3000"

  USERNAME = 'paolotax'
  PASSWORD = 'sisboccia'

  #server 
  APP_ID = "36e1b9ed802dc7ee45e375bf318924dc3ae0f0f842c690611fde8336687960eb"
  SECRET = "11ab577f8fabf2ac33bdd75e951fc6507ef7bc21ef993c2a77a1383bed438224"
  
  #ptax
  #APP_ID = "9aa427dcda89ebd5b3c9015dcd507242b70bac2a4d6e736589f6be35849474ff"
  #SECRET = "a5d78f0c32ba25fcbc1a679e03b110724497684263c1f4d9f645444cbf80a832"


  # login

  def login(block)
    data = {
      grant_type: 'password',
      client_id: APP_ID,
      client_secret: SECRET,
      username: USERNAME,
      password: PASSWORD
    }
    AFNetworkActivityIndicatorManager.sharedManager.enabled = true
    AFMotion::Client.build_shared(BASE_URL) do
      header "Accept", "application/json"

      operation :json
    end
    AFMotion::Client.shared.post("oauth/token", data) do |result|
      if result.success?

        token = result.object['access_token']
        puts "#{token}"
        self.backend.HTTPClient.setDefaultHeader("Authorization", value: "Bearer #{token}")

        block.call
      else
        puts result.error
      end
    end
  end








  # NO NEED TO CHANGE ANYTHING BELOW THIS LINE
  
  def self.shared
    # Our store is a singleton object.
    @shared ||= Store.new
  end
  
  def context
    @context
  end

  def persistent_context
    @persistent_context
  end

  def store
    @store
  end

  def backend
    @backend
  end

  def save
    error_ptr = Pointer.new(:object)
    unless @context.save(error_ptr)
      raise "Error when saving the model: #{error_ptr[0].description}"
    end
    
    # Clear caches, they will be reloaded on demand
    ManagedObjectClasses.each {|c| c.reset}
  end

  def persist
    error_ptr = Pointer.new(:object)
    unless @persistent_context.save(error_ptr)
      raise "Error when saving the model: #{error_ptr[0].description}"
    end
    
    # Clear caches, they will be reloaded on demand
    # ManagedObjectClasses.each {|c| c.reset}
  end

  def clear

    error = Pointer.new(:object)
    unless @store.resetPersistentStores(error)
      raise "Imporssibile eliminare lo store"
    end
    initialize
  end

  def stats
    puts "context inserted: #{@context.insertedObjects.count}"
    puts "context updated: #{@context.updatedObjects.count}"
    puts "context deleted: #{@context.deletedObjects.count}"

    puts "persist inserted: #{@persistent_context.insertedObjects.count}"
    puts "persist updated: #{@persistent_context.updatedObjects.count}"
    puts "persist deleted: #{@persistent_context.deletedObjects.count}"
  end

  private

  def initialize
    
    @model ||= NSManagedObjectModel.alloc.init.tap do |m|
      m.entities = ManagedObjectClasses.collect {|c| c.entity}
      m.entities.each {|entity| entity.wireRelationships}
    end

    url = NSURL.URLWithString(BASE_URL)
    @backend = RKObjectManager.managerWithBaseURL(url)

    @store = RKManagedObjectStore.alloc.initWithManagedObjectModel(@model)
    @backend.managedObjectStore = @store
    @backend.requestSerializationMIMEType = RKMIMETypeJSON

    store_path = RKApplicationDataDirectory().stringByAppendingPathComponent("Libri.sqlite")

    # error = Pointer.new(:object)
    # NSFileManager.defaultManager.removeItemAtPath(store_path, error:error)

    error_ptr = Pointer.new(:object)
    unless @store.addSQLitePersistentStoreAtPath(store_path,
                              fromSeedDatabaseAtPath:nil,
                                   withConfiguration:nil,
                                             options:{
                                                       NSInferMappingModelAutomaticallyOption: true,
                                                       NSMigratePersistentStoresAutomaticallyOption: true
                                                     },
                                               error:error_ptr)
      raise "Errore Inpossibile creare lo Store #{error_ptr[0].description}"
    end
    
    @store.createManagedObjectContexts

    @persistent_context = @store.persistentStoreManagedObjectContext
    @context = @store.mainQueueManagedObjectContext

    #RKlcl_configure_by_name("RestKit/Network", RKLogLevelTrace)
    #RKlcl_configure_by_name("RestKit/ObjectMapping", RKLogLevelTrace)

    MappingProvider.shared.init_mappings(@store, @backend)
  end

  


end