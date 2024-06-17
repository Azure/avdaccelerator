@sys.description('Required. Name of the Scaling Plan.')
param name string

@sys.description('Optional. Location of the Scaling Plan. Defaults to resource group location.')
param location string = resourceGroup().location

@sys.description('Optional. Time zone of the Scaling Plan. Defaults to UTC.')
param timeZone string = 'UTC'

@sys.description('Optional. Host pool type of the Scaling Plan.')
param hostPoolType string = 'Personal'

var schedules = [
  {
    daysOfWeek: [
      'Monday'
      'Wednesday'
      'Thursday'
      'Friday'
    ]
    name: 'prueba1'
    offPeakStartTime: {
      hour: 20
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    offPeakMinutesToWaitOnDisconnect: 30
    offPeakActionOnDisconnect: 'Hibernate'
    offPeakMinutesToWaitOnLogoff: 0
    offPeakActionOnLogoff: 'Deallocate'
    peakStartTime: {
      hour: 9
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    peakMinutesToWaitOnDisconnect: 30
    peakActionOnDisconnect: 'Hibernate'
    peakMinutesToWaitOnLogoff: 0
    peakActionOnLogoff: 'Deallocate'
    rampDownStartTime: {
      hour: 18
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampDownMinutesToWaitOnDisconnect: 30
    rampDownActionOnDisconnect: 'Hibernate'
    rampDownMinutesToWaitOnLogoff: 0
    rampDownActionOnLogoff: 'Deallocate'
    rampUpStartTime: {
      hour: 7
      minute: 0
    }
    rampUpAutoStartHosts: 'WithAssignedUser'
    rampUpStartVMOnConnect: 'Enable'
    rampUpMinutesToWaitOnDisconnect: 30
    rampUpActionOnDisconnect: 'Hibernate'
    rampUpMinutesToWaitOnLogoff: 0
    rampUpActionOnLogoff: 'Deallocate'
  }
  {
    daysOfWeek: [
      'Tuesday'
    ]
    name: 'prueba1-agent-updates'
    offPeakStartTime: {
      hour: 20
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    offPeakMinutesToWaitOnDisconnect: 30
    offPeakActionOnDisconnect: 'Hibernate'
    offPeakMinutesToWaitOnLogoff: 0
    offPeakActionOnLogoff: 'Shutdown'
    peakStartTime: {
      hour: 9
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    peakMinutesToWaitOnDisconnect: 30
    peakActionOnDisconnect: 'Hibernate'
    peakMinutesToWaitOnLogoff: 0
    peakActionOnLogoff: 'Shutdown'
    rampDownStartTime: {
      hour: 18
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampDownMinutesToWaitOnDisconnect: 30
    rampDownActionOnDisconnect: 'Hibernate'
    rampDownMinutesToWaitOnLogoff: 0
    rampDownActionOnLogoff: 'Shutdown'
    rampUpStartTime: {
      hour: 7
      minute: 0
    }
    rampUpAutoStartHosts: 'WithAssignedUser'
    rampUpStartVMOnConnect: 'Enable'
    rampUpMinutesToWaitOnDisconnect: 30
    rampUpActionOnDisconnect: 'Hibernate'
    rampUpMinutesToWaitOnLogoff: 0
    rampUpActionOnLogoff: 'Shutdown'
  }
  {
    daysOfWeek: [
      'Saturday'
      'Sunday'
    ]
    name: 'prueba2'
    offPeakStartTime: {
      hour: 18
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    offPeakMinutesToWaitOnDisconnect: 30
    offPeakActionOnDisconnect: 'Hibernate'
    offPeakMinutesToWaitOnLogoff: 0
    offPeakActionOnLogoff: 'Shutdown'
    peakStartTime: {
      hour: 10
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    peakMinutesToWaitOnDisconnect: 30
    peakActionOnDisconnect: 'Hibernate'
    peakMinutesToWaitOnLogoff: 0
    peakActionOnLogoff: 'Shutdown'
    rampDownStartTime: {
      hour: 16
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampDownMinutesToWaitOnDisconnect: 30
    rampDownActionOnDisconnect: 'Hibernate'
    rampDownMinutesToWaitOnLogoff: 0
    rampDownActionOnLogoff: 'Shutdown'
    rampUpStartTime: {
      hour: 9
      minute: 0
    }
    rampUpAutoStartHosts: 'None'
    rampUpStartVMOnConnect: 'Enable'
    rampUpMinutesToWaitOnDisconnect: 30
    rampUpActionOnDisconnect: 'Hibernate'
    rampUpMinutesToWaitOnLogoff: 0
    rampUpActionOnLogoff: 'Shutdown'
  }
]

resource scalingPlan 'Microsoft.DesktopVirtualization/scalingPlans@2023-09-05' = {
  name: name
  location: location
  properties: {
    timeZone: timeZone
    hostPoolType: hostPoolType
    schedules: (hostPoolType == 'Pooled') ? schedules : []
  }
}

resource scalingPlanSchedule 'Microsoft.DesktopVirtualization/scalingplans/personalSchedules@2024-03-06-preview' = [for schedule in schedules: if (hostPoolType == 'Personal') {
  name: '${schedule.name}'
  parent: scalingPlan
  properties: schedule
}]
