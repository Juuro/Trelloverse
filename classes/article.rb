class Article
	attr_accessor :title, :jalias, :description, :attachments
	
	def initialize(title, jalias, description, attachments)
		@title = title
		@jalias = jalias.downcase
		@description = description		
		@attachments = attachments
	end
end