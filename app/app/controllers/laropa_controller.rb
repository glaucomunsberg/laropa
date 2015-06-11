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

		query="SELECT distinct ?refBy ?id ?nodeAuthor2 ?nameArticle ?name ?rank ?nome ?conference ?nameConference ?year
			FROM <http://laburb.com>
			WHERE{
			   	?article a bibo:AcademicArticle .
			   	?article dc:title ?nameArticle .
			   	?article dcterms:isReferencedBy ?refBy .
			   	?article vivo:relatedBy ?nodeAuthor.
			   	?article dcterms:issued ?year .
			   	?nodeAuthor vivo:relates ?nodeAuthor2.
			   	?nodeAuthor vivo:rank ?rank .
			   	?nodeAuthor2 rdfs:label ?name .
			   	?refBy dc:creator ?personCreator.
			   	?personCreator rdfs:label ?nome.
			   	?article bibo:presentedAt ?conference.
			   	?conference dc:title ?nameConference .
                           		?refBy bibo:identifier ?id.
                           	FILTER (?refBy != <http://ufpel.edu.br/lattes/6927803856702261>).
                                 	FILTER (!regex(str(?nodeAuthor2), concat(\"#author-\",str(?id))))
			} ORDER BY ?refBy"
		connection = ConnectionSPARQL.new
		data = connection.runQuery(query);
		first, *rest = query.split(/FROM/)
		cont = first.scan("?").count
		@result = csvToArray(data, cont)
		respond_with(@result)
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
end
