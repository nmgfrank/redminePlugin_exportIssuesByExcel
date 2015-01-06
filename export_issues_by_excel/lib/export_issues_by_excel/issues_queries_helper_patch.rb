
require_dependency 'spreadsheet'
require_dependency 'queries_helper'

module QueriesHelperPatch
    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do 
                
        end
    end

    module InstanceMethods
          def query_to_xlsx(items, query, status_names = nil, options={})
            xls_export = StringIO.new  
          
            Spreadsheet.client_encoding = "UTF-8"  
            
            book = Spreadsheet::Workbook.new
            
            sheet1 = book.create_worksheet :name => "Users"  
            
            head_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10
            sheet1.row(0).default_format = head_format

            columns = (options[:columns] == 'all' ? query.available_inline_columns : query.inline_columns)
            query.available_block_columns.each do |column|
                if options[column.name].present?
                    columns << column
                end
            end 
            col_cnt = 0  

            columns.each do |col|
                sheet1[0,col_cnt] =  Redmine::CodesetUtil.from_utf8(col.caption.to_s,"UTF-8")
                col_cnt += 1
            end  
            
            if !status_names.blank?
                status_names.each do |status_name|
                    sheet1[0,col_cnt] =  Redmine::CodesetUtil.from_utf8(status_name,"UTF-8")
                    col_cnt += 1                
                end
            end    

            count_row = 1  
            items.each do |item|
                issue = item[:issue]
                status_changes = item[:status_change]
            
                col_cnt = 0
                columns.each do |column|
                    sheet1[count_row,col_cnt]=Redmine::CodesetUtil.from_utf8(csv_content(column, issue), "UTF-8")
                    col_cnt += 1
                end 
                
                if !status_names.blank?
                    status_names.each do |status_name|
                        sheet1[count_row,col_cnt]=Redmine::CodesetUtil.from_utf8(status_changes[status_name].blank? ? "" : status_changes[status_name].strftime('%Y-%m-%d %H:%M:%S'), "UTF-8")
                        col_cnt += 1 
                    end   
                end
                  
                count_row += 1  
            end  
  
            book.write xls_export 
            xls_export.string            
          end

    end
end

QueriesHelper.send(:include, QueriesHelperPatch)
