#d Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def status_bread_trail(entity)   
    return entity.get_all_statuses.join(" -> ")    
  end

  def pdf_link_with_del(pdf, html_options = {})
    #html_options[:onmouseover] = "$('pdf_#{pdf.id}').addClassName('on');" 
    #html_options[:onmouseout] = "$('pdf_#{pdf.id}').removeClassName('on');" 
    "<span id='pdf_#{pdf.id}' class='pdf_links' onmouseover='$(\"pdf_#{pdf.id}\").addClassName(\"on\");' onmouseout='$(\"pdf_#{pdf.id}\").removeClassName(\"on\");'>".html_safe + pdf_link(pdf, html_options) + del_pdf_link(pdf) + '</span>'.html_safe
  end 

  def del_pdf_link(pdf, html_options = {})
    html_options[:confirm] = 'Are you sure? This CANNOT be undone'
    html_options[:class] ||= ''
    html_options[:class] += ' pdf_del_link'
    link_to_remote "delete", {:url => del_pdf_url(pdf)}, html_options
  end

  def del_pdf_url(pdf, html_options = {})
    url_for html_options.merge(:action => :destroy, :controller => :pdfs, :id => pdf)
  end

  def pdf_link(pdf, html_options = {})
    html_options[:class] ||= ''
    html_options[:class] += ' pdf_link'
    html_options[:target] = "_blank"
    text = html_options[:text] || pdf.file
    link_to text, pdf_url(pdf), html_options
  end

  def pdf_url(pdf, html_options = {})
    url_for html_options.merge(:action => :get_pdf, :controller => :pdfs, :id => pdf)
  end
  
  def pre_title_select(model, method, html_options = {})
    select model, method, ['Dr.', 'Mr.', 'Ms.', 'Mrs.', 'Professor'], { :include_blank => true }, html_options
  end
  
  def degrees_for_select
    @degrees ||= Degree.find(:all, :order=>:position, :conditions => 'name IS NOT NULL').collect {|d| [d.name, d.name] }.push(['Other', 'Other'])
  end
  
  def state_province_select(f = nil)
    if f
      f.collection_select :state_province_id, StateProvince.find(:all, :order => 'state_province_id'), :state_province_id, :state_name, { :include_blank => true }
    else
      collection_select :user, :state_province_id, StateProvince.find(:all, :order => 'state_province_id'), :state_province_id, :state_name, { :include_blank => true }
    end
  end
  
  def country_select(f = nil)
    if f
      f.collection_select :country_id, Country.find(:all, :order => 'display_order'), :country_id, :country_name, { :include_blank => true }
    else
      collection_select :user, :country_id, Country.find(:all, :order => 'display_order'), :country_id, :country_name, { :include_blank => true }
    end
  end
  
  def article_section_select(f = nil)   
    if f
      f.collection_select :article_section_id, ArticleSection.find_all_by_public(1, :order=>'display_order'), :article_section_id, :display_name , { :include_blank => true }
    else
      collection_select :article_submission, :article_section_id, ArticleSection.find_all_by_public(1, :order=>'display_order'), :article_section_id, :display_name, { :include_blank => true }
    end
  end
  
  def yes_no_radio(model, method, current_value,onclick="check_field(this, this.value)")
    if current_value.nil?
      radio_button(model, method, 1, {:onclick =>onclick}) + 
        "<label for=\"#{model.to_s}_#{method.to_s}_1\" >".html_safe + get('yes_' + model.to_s + method.to_s) + "</label>".html_safe +
      radio_button(model, method, 0, {:onclick => onclick}) +
        "<label for=\"#{model.to_s}_#{method.to_s}_0\" >".html_safe + get('no_' + model.to_s + method.to_s) + "</label>".html_safe
    elsif current_value == true
            radio_button(model, method, 1, {:onclick =>onclick, :checked => 'checked' }) + 
        "<label for=\"#{model.to_s}_#{method.to_s}_1\" >".html_safe + get('yes_' + model.to_s + method.to_s) + "</label>".html_safe +
      radio_button(model, method, 0, {:onclick => onclick}) +
        "<label for=\"#{model.to_s}_#{method.to_s}_0\" >".html_safe + get('no_' + model.to_s + method.to_s) + "</label>".html_safe
    else
      radio_button(model, method, 1, {:onclick => onclick }) + 
        "<label for=\"#{model.to_s}_#{method.to_s}_1\" >".html_safe + get('yes_' + model.to_s + method.to_s) + "</label>".html_safe +
      radio_button(model, method, 0, {:onclick => onclick, :checked => 'checked'}) +
        "<label for=\"#{model.to_s}_#{method.to_s}_0\" >".html_safe + get('no_' + model.to_s + method.to_s) + "</label>".html_safe
    end
  end
  
  # returns css to hide an element, should the var agree with the given hide_state
  def hide_on(hide_state, var, on_nil = true)
    hiding_css = 'style="display: none;"'
    
    js = ''
#    js = " onclick=\"check_field(this)\""
#    logger.info "---> var.class=#{var.class}"
    
    if var.nil? and on_nil
      return hiding_css + js
    elsif var.nil? and ! on_nil
      return js
    end
    
    if hide_state
      return var ? hiding_css + js : js
    else
      return var ? js : hiding_css + js
    end
  end

#  def yes_or_no(state)
#    state ? "Yes" : "No"
#  end
  
  def yes_or_no(model, method, current_value)
    case current_value
    when true
     get('yes_' + model.to_s + method.to_s)
   else
     get('no_' + model.to_s + method.to_s)
   end
  end
 
  def simple_yes_or_no(state)
    state ? 'Yes' : 'No' 
  end 
 
  def print_and_continue_button(msg)
    return "<script type='text/javascript'>function print_and_alert() { window.print(); alert(\"#{msg}\"); } </script><input class=\"submit\" accesskey=\"p\" value=\" PRINT THIS FORM \" name=\"submit\" type=\"submit\" onclick=\"print_and_alert(); return false;\" />";
  end
  
  
     #   This Copyright Assignment, Financial Disclosure Disclosure or Author Responsibility Form [Insert correct form name] has been completed by __________________ 
    # on his/her own behalf and/or on behalf of _____________________________ [insert name of organization/institution and your title].

    #    □ I hereby assent to the terms of this agreement and accept all obligations it imposes on me and/or on ________________ [insert name of entity].

    #    I understand that each contributor to the manuscript that is the subject of this agreement is also required to execute a separate Copyright Assignment, 
    #Financial Disclosure Disclosure Form  or Author Responsibility Form  [Insert correct form name].
     
  def signature_block(object_name, form_name, field_prefix = '')
    out = "<div class='group sigblock'>This #{form_name} has been completed by&nbsp;".html_safe 
    if @generating_pdf 
       out += self.instance_variable_get('@' + object_name).send(field_prefix + 'sig_completed_by')
    else
       out += text_field(object_name, field_prefix + 'sig_completed_by') +  " on his/her own behalf"
    end

    unless @generating_pdf and  self.instance_variable_get('@' + object_name).send(field_prefix + 'sig_entity_title').blank? 
#      out += "and/or on behalf of&nbsp;"
#      if @generating_pdf
#        out += self.instance_variable_get('@' + object_name).send(field_prefix + 'sig_entity_title') 
#      else
#        out += text_field(object_name, field_prefix + 'sig_entity_title') + "&nbsp;[insert name of organization/institution and your title]"
#      end
    end
    out += ". <br /><br />".html_safe

    unless @generating_pdf
      out += check_box(object_name, field_prefix + 'sig_assent') + ' '
    end

    out += "I hereby assent to the terms of this agreement and accept all obligations it imposes me" 
    unless @generating_pdf and self.instance_variable_get('@' + object_name).send(field_prefix + 'sig_entity').blank?
#      out += " and/or on&nbsp;"
#      if @generating_pdf
#        out += self.instance_variable_get('@' + object_name).send(field_prefix + 'sig_entity') 
#      else
#        out += text_field(object_name, field_prefix + 'sig_entity') + "&nbsp;[insert name of organization/institution]"
#      end
    end
    out += "."
    if @generating_pdf
      out += "<br />Yes".html_safe
    end
    out += "</div> <br /><br />".html_safe
    out
  end
  
    def coi_signature_block(object_name, form_name, field_prefix = '')
    out = "<div class='roup coi_sigblock'><div>".html_safe
    if @generating_pdf 
       out += self.instance_variable_get('@' + object_name).send(field_prefix + 'sig_completed_by')
    else
       out += text_field(object_name, field_prefix + 'sig_completed_by') +  "<br/> Signature of Reporting Individual".html_safe
    end
    out << "</div>".html_safe
    out << "<div id='date_block'><span>#{fmt_date(Time.now)}</span><br/>Date of Submission</div>".html_safe
    out << "</div>".html_safe
    out << "<div style='clear:both'/>".html_safe
    return out
  end

  def observe_fields(params)
    out = ''
    params[:fields].each do |f|
      out += "<script>Event.stopObserving('#{f.to_s}');</script>"
      out += observe_field(f.to_s, :with=>f.to_s, :url => params[:url].clone.delete_if{|k,v| k==f})
    end
    out
  end

  def form_indicator
    @@form_indicator ||= '<span id="form-indicator" style="display: none;">' + image_tag("form-indicator.gif") + '</span>'
  end
  
  def coi_form_title(coi_form)
    if coi_form.previous
      "This disclosure was last updated #{@coi_form.previous.committed.strftime("%B %e, %Y")}"
    else
      "Initial disclosure: #{Time.now.strftime("%B %e, %Y")}"
    end
  end
  
  def all_roles_for_options
    @@all_roles_for_options ||= Role.find(:all).collect{|r| [r.role_title, r.id]}.unshift(['-', nil])
  end
 
  # spit out a template from the db
  def get(template_alias, template_var = nil, html_edit = 'yes')
    html_edit = html_edit ? 'yes' : 'no'
    if(current_user && current_user.has_admin? and ! @generating_pdf)
      @footer_text ||= javascript_tag('Event.observe(window, "load", placeTemplateLinks);')
      @footer_text += "<div id='#{template_alias}_edit_link' class='ut_edit_link dontprint' style='display: none;' >" + 
                      link_to_remote_redbox( 'edit', :url => url_for( :controller => '/user_templates', 
                                                     :action => 'edit_inline', 
                                                     :template_alias => template_alias, 
                                                     :html_edit => html_edit,
                                                     :id => '')
                                            ) + 
                       "</div>" + 
                javascript_tag(" if (!window.templates) {window.templates = new Array();}; window.templates.push('#{template_alias}'); ")
    end
    
    "<span id='ut_#{template_alias}' class='template_text'>".html_safe + 
       UserTemplate.get_template(template_alias, template_var).html_safe + 
    "</span>".html_safe
    
  end
  
  def get_template_text(template_alias,template_var=nil)
      UserTemplate.get_template(template_alias, template_var)
  end

  def link_to_function(name, *args, &block)
     html_options = args.extract_options!.symbolize_keys

     function = block_given? ? update_page(&block) : args[0] || ''
     onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; GiveFalse(); return false;"
     href = html_options[:href] || '#'

     content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
  end

  def yes_no_question(object_name, method_name, options = {})
    object_name = object_name.to_s
    method_name = method_name.to_s
    object = self.instance_variable_get('@' + object_name)
    out = ''
    if options[:table]
      options[:label] ||= object_name + "_" + method_name + "_label"
      value = object.send(method_name)
      out += '<tr>' + "\n"
        out += '<td class="questionlabel-1">'
        out += '<span class="requiredflag">*</span>' if options[:required]
        out += '<label>' + get(options[:label].to_s) + '</label></td>' + "\n"
          out += '<td  class="array2">' + "\n"
          out += yes_no_radio object_name, method_name, value
          out += '<span class="note">' + get("#{object_name}_#{method_name}_note") + '</span>'
          unless options[:details_on].nil?
            out += "<span id='#{object_name}_#{method_name}_span' #{hide_on(! options[:details_on], value)}>"
            out += '&nbsp;&nbsp;&nbsp;'
            out += '<span class="note">' + get("#{object_name}_#{method_name}_if_details") + '</span>'
            out += '<br />'
            out += text_area object_name, options[:details_name] || (method_name + '_details'), :rows=>"3", :cols=>"40"
            out += '</span>'
          end
          out += '</td>' + "\n"
        out += '</tr>' + "\n"
    else
      options[:label] ||= object_name + "_" + method_name + "_label"
      value = object.send(method_name)
      out += '<div class="question">' + "\n"

        out += '<div class="question-text">'
        out += '<span class="requiredflag">*</span>' if options[:required]
        out += '<label>' + get(options[:label].to_s) + '</label></div>' + "\n"

          out += '<div class="answer">' + "\n"
          out += yes_no_radio object_name, method_name, value
          out += '<span class="note">' + get("#{object_name}_#{method_name}_note") + '</span>'
          unless options[:details_on].nil?
            out += "<span id='#{object_name}_#{method_name}_span' #{hide_on(! options[:details_on], value)}>"
            out += '&nbsp;&nbsp;&nbsp;'
            out += '<span class="note">' + get("#{object_name}_#{method_name}_if_details") + '</span>'
            out += '<br />'
            out += text_area object_name, options[:details_name] || (method_name + '_details'), :rows=>"3", :cols=>"40"
            out += '</span>'
          end
          out += '</div><div class="clear"></div>' + "\n"
        out += '</div>' + "\n"
    end
    out.html_safe
  end

  def yes_question(object_name, method_name, options = {})
    object_name = object_name.to_s
    method_name = method_name.to_s
    object = self.instance_variable_get('@' + object_name)
    out = ''
    if options[:table]
      options[:label] ||= object_name + "_" + method_name + "_label"
      value = object.send(method_name)
      out += '<tr>' + "\n"
        out += '<td class="questionlabel-1">'
        out += '<span class="requiredflag">*</span>' if options[:required]
        out += '<label>' + get(options[:label].to_s) + '</label></td>' + "\n"
          out += '<td  class="array2">' + "\n"
          out += check_box(object_name, method_name) + "&nbsp;" + get("#{object_name}_#{method_name}_yes")
          out += '</td>' + "\n"
        out += '</tr>' + "\n"
    else
      options[:label] ||= object_name + "_" + method_name + "_label"
      value = object.send(method_name)
      out += '<div class="question">' + "\n"
        out += '<div class="question-text">'
        out += '<span class="requiredflag">*</span>' if options[:required]
        out += '<label>' + get(options[:label].to_s) + '</label></div>' + "\n"
          out += '<div class="answer">' + "\n"
          out += check_box(object_name, method_name) + "&nbsp;" + get("#{object_name}_#{method_name}_yes")
          out += '</div><div class="clear"></div>' + "\n"
        out += '</div>' + "\n"
    end
    out.html_safe
  end


  def progress_link(complete,no_float=false)
     klass = no_float ? "progress_icon_no_float" : "progress_icon"
     if complete
       image_tag("done.png",:class=>klass)
     else
       image_tag("not_done.png",:class=>klass)
     end   
  end

  # Returns the STRING 'complete' or 'not-complete' depending on the given true or false value.
  # This is used to give a css class for the manuscript checklist
  def complete_or_not(bool)
    bool ? 'complete' : 'not-complete'
  end
  
   def bool_display(model,method)
     bool = model.send(method)  
     val = bool ? "yes" : "no"  
     return get(val+ '_' + model.class.to_s.downcase + method)
 end
 
    
    def tool_tip(id,content)
    #    temp = UserTemplate.get_template(content)
    #    msg = temp || content
        html = link_to_function('?',"show_tool_tip('tool_tip_#{id}',\"#{content}\")",:id => "tool_tip_#{id}")
    #    if(current_user.has_admin? && temp.class == UserTemplate)
    #      html << "<br/><br/>"
    #      html <<  link_to_remote_redbox( 'edit', :url => url_for( :controller => '/user_templates', :action => 'edit_inline', :template_alias => temp.alias, :id => ''))
    #    end
     return html
    end
    
    
    
    # If passed a DateTime or Time: Return a String of the formatted version of a given date
    # If passed an Array: For all elements that respond to 'strftime' method, format the elements, return the others untouched, Return the final array
    # TODO: Store this format in the DB in a config table (AMA - 12 Nov 2010)
    def fmt_date_time(obj)
      if obj.class == Array 
        return obj.collect {|e| fmt_date(e)}
      elsif obj.respond_to?('strftime')
        return obj.strftime("%m/%d/%Y at %I:%M%p") 
      else
        return obj
      end
    end
    
    # If passed a Date/Time/DateTime: Return a String of the formatted version of a given date
    # If passed an Array: For all elements that respond to 'strftime' method, format the elements, return the others untouched, Return the final array
    # TODO: Store this format in the DB in a config table (AMA - 12 Nov 2010)
    def fmt_date(obj)
      if obj.class == Array 
        return obj.collect {|e| fmt_date(e)}
      elsif obj.respond_to?('strftime')
        return obj.strftime("%m/%d/%Y") 
      else
        return obj
      end
    end

    # switch between even or odd, helpful with alternating styles
    # Returns a string 'even' or 'odd'
    # Accepts a String of 'even' or 'odd' to set the initial value. Defaults to 'odd'
    def even_or_odd(initial_value = 'odd')
        if @value == 'even' 
            @value = 'odd'
        elsif @value == 'odd'
            @value = 'even'
        else 
            @value = initial_value.to_s
        end
        @value
    end
end



class String
  def trunc(n)
    if self.length > n - 3
      self[0..(n - 4)] + '...'
    else
      self
    end
  end
end


class TrueClass
  def to_i
    1
  end
end

class FalseClass
  def to_i
    0
  end
end


