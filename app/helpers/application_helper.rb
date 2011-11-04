# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper 
    def self.append_features(controller) 
      controller.ancestors.include?(ActionController::Base) ? 
        controller.add_template_helper(self) : super 
    end 
    def show_image(src) 
       img_options = { "src" => src.include?("/") ? src : "/images/#{src}" } 
       img_options["src"] = img_options["src"] + ".png" unless 
img_options["src"].include?(".") 
       img_options["border"] = "0" 
       tag("img", img_options) 
    end 
end 

