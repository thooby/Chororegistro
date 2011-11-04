require_dependency "search"
require_dependency "search2"
class Persona < ActiveRecord::Base
   belongs_to :vive
   validates_associated :vive 
   belongs_to :zona
   validates_associated :zona
   belongs_to :indigena
   validates_associated :indigena
   searches_on :all
end
