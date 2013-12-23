module PersonalInformation
  #admin portal related
  #the name of your project
  ProjectName = ""
  #the password to access the administrator's portal
  AdminPassword = ""
  #server information
  #The IP address of your development server
  DevServer = "localhost:3000"
  #The IP address of the production server
  ProdServer = ""
  #MTurk information
  #The access key ID provided by Amazon (see aws.amazon.com)
  AwsAccessKeyID = ""
  #The secret key provided by Amazon (see aws.amazon.com)
  AwsSecretKey = ""
  #contact information
  #where do crash reports get sent to?
  Email = "big5marketingco@gmail.com"
  #when contacting a worker, how do you sign the email?
  MTurkWorkerContactFormSignature = ""

  #experimental variables
  CURRENT_EXPERIMENTAL_VERSION_NO = 1
  ExperimentalModel = Task
  ExperimentalController = :task
end


