root = global ? window
constants =
    defaultURL : 'https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv?dl=1'

Meteor.startup ->
    if root.Meteor.is_client
        Session.set('currentDatasetURL', constants.defaultURL)
        Session.set('currentGroup', '')
        Meteor.call("get_fields",Session.get('currentDatasetURL'))
        Meteor.call('register_dataset',Session.get('currentDatasetURL'))


