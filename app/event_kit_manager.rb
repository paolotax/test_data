class EventKitManager

  attr_accessor :eventStore, :reminders, :reminderAccess, :eventAccess, :fetchQueue

  def initialize

    if self
      @eventStore = EKEventStore.alloc.init
      @eventStore.requestAccessToEntityType(EKEntityTypeEvent,
                  completion:lambda do |granted, error| 
                    if (granted)
                      @eventAccess = true
                      "EventsAccessGranted".post_notification(self)
                    else
                      puts "Non puoi accedere al calendario!"
                    end
                  end
      )
      @eventStore.requestAccessToEntityType(EKEntityTypeReminder,
                  completion:lambda do |granted, error| 
                    if (granted)
                      @reminderAccess = true
                      @eventAccess = true
                      "RemindersAccessGranted".post_notification(self)
                    else
                      puts "Non puoi accedere ai promemoria!"
                    end
                  end
      )
      @fetchQueue = Dispatch::Queue.new("com.taxSoft.youpropa.fetchQueue")  # !!!!!!!, DISPATCH_QUEUE_SERIAL)
    end

    self
  end


  def addReminderWithTitle(title, dueTime:dueDate)
    
    unless @reminderAccess
      puts "Non puoi accedere ai promemoria! Boia!"
      return
    end
       
    reminder = EKReminder.reminderWithEventStore(self.eventStore)
    reminder.title = title
    reminder.calendar = self.calendarForReminders
    
    calendar = NSCalendar.currentCalendar
    unitFlags = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit
    dueDateComponents = calendar.components(unitFlags, fromDate:dueDate)
    reminder.dueDateComponents = dueDateComponents
    
    alarm = EKAlarm.alarmWithRelativeOffset(0)
    reminder.addAlarm(alarm)

    error = Pointer.new(:object)
    success = self.eventStore.saveReminder(reminder, commit:true, error:error)
    unless success
      puts "There was an error saving the reminder #{error}"
    else
      puts reminder.calendarItemExternalIdentifier
    end

  end

  def calendarForReminders
    
    for calendar in self.eventStore.calendarsForEntityType(EKEntityTypeReminder)
      if calendar.title.isEqualToString("you") 
        return calendar
      end
    end

    remindersCalendar = EKCalendar.calendarForEntityType(EKEntityTypeReminder, eventStore:self.eventStore)
    remindersCalendar.title = "you"
    remindersCalendar.source = self.eventStore.defaultCalendarForNewReminders.source
    
    error = Pointer.new(:object)
    success = self.eventStore.saveCalendar(remindersCalendar, commit:true, error:error)
    unless success
      puts "There was an error creating the reminders calendar"
      return nil
    end
    return remindersCalendar
  end

  def fetchAllReminders 

    predicate = self.eventStore.predicateForRemindersInCalendars([self.calendarForReminders])
    self.eventStore.fetchRemindersMatchingPredicate(predicate,
        completion:lambda do |reminders|
          self.reminders = reminders.mutableCopy
          "RemindersModelChangedNotification".post_notification(self)
        end
    )
  end


end