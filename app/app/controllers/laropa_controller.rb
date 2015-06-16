require 'net/http'
require 'cgi'
require 'csv'
require 'ConnectionSPARQL'
require 'rubygems'
require 'rubygems'
require 'active_support/all'
$KCODE = 'UTF8'

class LaropaController < ApplicationController

respond_to :html, :json, :js

	def index

	end


#######################################################
# Transforma os dados vindos do vituoso do formato CSV para um Array com Hash
# --> Entrada: Array em CSV
# --> Saida: Array
#######################################################
	def csvToArray (data, contFields)
		i = 0;
		triples = Array.new
		cont = false
		data.each do |row|
			if cont == false
				row.pop
				cont = true
			else
				line = Hash.new
				while i < contFields do
   					line[i] = row[i].encode("ASCII-8BIT").force_encoding("utf-8")
   					i += 1
   				end
				triples.push(line)
				i = 0
			end
		end
		logger.info triples
	return triples
	end


	def loadQuery
		temp = "count"

		query = params["query"]
		connection = ConnectionSPARQL.new
		data = connection.runQuery(query);
		@result = Hash.new
		first, *rest = query.split(/FROM/)
		cont = first.scan("?").count
		if first.include? temp
			cont+=1;
		end

		@result["content"] = csvToArray(data, cont)
		@result["cont"] = cont
		respond_to do |format|
		 format.json { render :json => @result}

		end
	end
end


