class MappingProvider  

  def self.shared
    # Our store is a singleton object.
    @shared ||= MappingProvider.new
  end

  def init_mappings(store, backend)

    @store = store
    @backend = backend

    add_response_mapping(libro_mapping, "libro")
    add_response_mapping(libro_mapping, "libri")
    add_request_mapping(request_libro_mapping.inverseMapping, "libro", Libro)
    add_route_set(Libro,   "api/v1/libri",   "api/v1/libri/:LibroId")

    add_response_mapping(cliente_mapping, "cliente")
    add_response_mapping(cliente_mapping, "clienti")
    add_request_mapping(cliente_mapping.inverseMapping, "cliente", Cliente)
    add_route_set(Cliente, "api/v1/clienti", "api/v1/clienti/:ClienteId")

    add_response_mapping(appunto_mapping, "appunto")
    add_response_mapping(appunto_mapping, "appunti")
    add_request_mapping(request_appunto_mapping.inverseMapping, "appunto", Appunto)
    add_route_set(Appunto, "api/v1/appunti", "api/v1/appunti/:remote_id")

    add_response_mapping(riga_mapping, "riga")
    add_response_mapping(riga_mapping, "righe")
    add_request_mapping(request_riga_mapping.inverseMapping, "riga", Riga)
    add_route_set(Riga,
                  "api/v1/appunti/:remote_appunto_id/righe",
                  "api/v1/appunti/:remote_appunto_id/righe/:remote_id")

    # add_response_mapping(classe_mapping, "classe")
    # add_response_mapping(classe_mapping, "classi")

    # add_response_mapping(adozione_mapping, "adozione")
    # add_response_mapping(adozione_mapping, "adozioni")

    # add_response_mapping(docente_mapping, "docente")
    # add_response_mapping(docente_mapping, "docenti")

  end

  def add_response_mapping(mapping, path)
    successCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)
    descriptor = RKResponseDescriptor.responseDescriptorWithMapping(mapping,
                                                               pathPattern: nil,
                                                               keyPath: path,
                                                               statusCodes: successCodes)
    @backend.addResponseDescriptor(descriptor)
  end

  def add_request_mapping(mapping, path, klass)
    request_descriptor = RKRequestDescriptor.requestDescriptorWithMapping(mapping,
                                                                          objectClass: klass,
                                                                          rootKeyPath: path)
    @backend.addRequestDescriptor(request_descriptor)
  end

  def add_route_set(klass, collection_path, resource_path)
    get_route = RKRoute.routeWithClass(klass, 
                                       pathPattern: resource_path,
                                       method: RKRequestMethodGET)
    put_route = RKRoute.routeWithClass(klass, 
                                       pathPattern: resource_path,
                                       method: RKRequestMethodPUT)
    delete_route = RKRoute.routeWithClass(klass, 
                                          pathPattern: resource_path,
                                          method: RKRequestMethodDELETE)
    post_route = RKRoute.routeWithClass(klass, 
                                        pathPattern: collection_path,
                                        method: RKRequestMethodPOST)
    
    @backend.router.routeSet.addRoute(get_route)
    @backend.router.routeSet.addRoute(put_route)
    @backend.router.routeSet.addRoute(delete_route)
    @backend.router.routeSet.addRoute(post_route)
  end


  # Mappings

  def libro_mapping
    @libro_mapping ||= begin
      mapping = RKEntityMapping.mappingForEntityForName("Libro",
                                       inManagedObjectStore:@store)
      mapping.identificationAttributes = [ "LibroId" ]
      mapping.addAttributeMappingsFromDictionary(id: "LibroId",
                                                 titolo: "titolo",
                                                 settore: "settore",
                                                 prezzo_copertina: "prezzo_copertina",
                                                 prezzo_consigliato: "prezzo_consigliato"
                                                )
    end
  end

  def request_libro_mapping
    @request_libro_mapping ||= begin
      mapping = RKEntityMapping.mappingForEntityForName("Libro",
                                       inManagedObjectStore:@store)
      mapping.addAttributeMappingsFromDictionary(titolo: "titolo",
                                                 prezzo_copertina: "prezzo_copertina", 
                                                 prezzo_consigliato: "prezzo_consigliato",
                                                 settore: "settore" 
                                                 )
    end
  end

  def cliente_mapping
    @cliente_mapping ||= begin
      mapping = RKEntityMapping.mappingForEntityForName("Cliente",
                                       inManagedObjectStore:@store)
      mapping.identificationAttributes = [ "ClienteId" ]
      mapping.addAttributeMappingsFromDictionary(id: "ClienteId",
                                                 titolo: "nome",
                                                 comune: "comune",
                                                 frazione: "frazione",
                                                 cliente_tipo: "cliente_tipo",
                                                 indirizzo: "indirizzo",
                                                 cap: "cap",
                                                 provincia: "provincia",
                                                 telefono: "telefono",
                                                 email: "email",
                                                 latitude: "latitude",
                                                 longitude: "longitude"
                                                 )
      # mapping.addPropertyMapping(RKRelationshipMapping.relationshipMappingFromKeyPath("appunti", 
      #                                 toKeyPath:"appunti", withMapping:appunto_mapping))
      # mapping.addPropertyMapping(RKRelationshipMapping.relationshipMappingFromKeyPath("classi", 
      #                                toKeyPath:"classi", withMapping:classe_mapping))
      # mapping.addPropertyMapping(RKRelationshipMapping.relationshipMappingFromKeyPath("docenti", 
      #                                toKeyPath:"docenti", withMapping:docente_mapping))
    end
  end

  def appunto_mapping
    @appunto_mapping ||= begin
      mapping = RKEntityMapping.mappingForEntityForName("Appunto",
                                       inManagedObjectStore:@store)
      
      mapping.identificationAttributes = [ "remote_id" ]
      mapping.addAttributeMappingsFromDictionary(id: "remote_id",
                                                 destinatario: "destinatario",
                                                 note: "note",
                                                 status: "status",
                                                 telefono: "telefono",
                                                 cliente_id: "ClienteId",
                                                 created_at: "created_at",
                                                 updated_at: "updated_at",
                                                 totale_copie: "totale_copie",
                                                 totale_importo: "totale_importo",
                                                 cliente_nome: "cliente_nome"
                                                 )
      mapping.addPropertyMapping(RKRelationshipMapping.relationshipMappingFromKeyPath("cliente", 
                                      toKeyPath:"cliente", withMapping:cliente_mapping))
      # togliere e mettere
      #mapping.addPropertyMapping(RKRelationshipMapping.relationshipMappingFromKeyPath("righe", toKeyPath:"righe", withMapping:riga_mapping))
    end 
  end

  def request_appunto_mapping
    @request_appunto_mapping ||= begin
      mapping = RKEntityMapping.mappingForEntityForName("Appunto", inManagedObjectStore:@store)
      mapping.addAttributeMappingsFromDictionary(destinatario: "destinatario",
                                                 note: "note",
                                                 status: "status",
                                                 telefono: "telefono",
                                                 cliente_id: "ClienteId")
      mapping.addPropertyMapping(RKRelationshipMapping.relationshipMappingFromKeyPath("righe_attributes", toKeyPath:"righe", withMapping:request_riga_mapping))
    end
  end

  def riga_mapping
    @riga_mapping ||= begin
      mapping = RKEntityMapping.mappingForEntityForName("Riga", inManagedObjectStore:@store)
      mapping.identificationAttributes = [ "remote_id" ]
      mapping.addAttributeMappingsFromDictionary(id: "remote_id",
                                         appunto_id: "remote_appunto_id",
                                           libro_id: "libro_id",
                                         fattura_id: "fattura_id",
                                             titolo: "titolo",
                                    prezzo_unitario: "prezzo_unitario",
                                   prezzo_copertina: "prezzo_copertina",
                                 prezzo_consigliato: "prezzo_consigliato",
                                           quantita: "quantita",
                                             sconto: "sconto",
                                            importo: "importo"
                                           )
      # togliere e mettere
      mapping.addPropertyMapping(RKRelationshipMapping.relationshipMappingFromKeyPath("appunto",toKeyPath:"appunto", withMapping:appunto_mapping))
      
      mapping.addPropertyMapping(RKRelationshipMapping.relationshipMappingFromKeyPath("libro", 
                                      toKeyPath:"libro", withMapping:libro_mapping))
    end
  end

  def request_riga_mapping
    @request_riga_mapping ||= begin
      mapping = RKEntityMapping.mappingForEntityForName("Riga", inManagedObjectStore:@store)
      mapping.addAttributeMappingsFromDictionary(
                                           libro_id: "libro_id",
                                        fattura_id: "fattura_id",
                                    prezzo_unitario: "prezzo_unitario",
                                           quantita: "quantita",
                                             sconto: "sconto")
    end
  end

end