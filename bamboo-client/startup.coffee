root = global ? window
constants =
    defaultURL : 'https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv?dl=1'

Meteor.startup ->
    if root.Meteor.is_client
        Meteor.defer(->
            $('.chosen').chosen()
        )
###
        Session.set('currentDatasetURL', constants.defaultURL)
        Session.set('currentGroup', '')
        Meteor.call('register_dataset',Session.get('currentDatasetURL'))
        Meteor.call("get_fields",Session.get('currentDatasetURL'))
        #TODO think about "everything" field, for now it is in the startup
        Meteor.call('summarize_by_group',[Session.get('currentDatasetURL'),""])
###


