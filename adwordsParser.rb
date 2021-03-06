require 'csv'
require 'open-uri'
class AdwordsParser
  
  def initialize(filename)
    @campaigns = []
    @campData = {}
    @adGroups = []
    @agData = {}
    @agMap = {}
    @ads = {}
    @kws = {}
    @negs = {}
    @filename = filename
  end
  
  def campaigns
    @campaigns
  end
  
  def campData
    @campData
  end
  
  def adGroups
    @adGroups
  end
  
  def agData
    @agData
  end
  
  def agMap
    @agMap
  end
  
  def ads
    @ads
  end
  
  def kws
    @kws
  end
  
  def negs
    @negs
  end
  
  def parseCampaigns
    self.getCampaigns()
    self.getCampaignData()
    self.getAdGroups()
    self.getAdGroupData()
    self.mapAdGroups()
    self.getAds()
    self.getKeywords()
    self.getNegatives()
  end
  
  def getCampaigns
    #Open AdWords CSV
    adwords = CSV.foreach("#{@filename}", headers:true) do |row|
      campName = row['Campaign']
      #If campaign name doesn't exist in the array, add it
      if (@campaigns.include? campName) || (campName.nil?)
        next
      else
        @campaigns << campName
      end
    end
  end
  
  def getCampaignData
    adwords = CSV.foreach("#{@filename}", headers:true) do |row|
      #Get the first data row for each campaign in the CSV
      if !(row['Campaign Type'].nil?)
        @campData[row['Campaign']] = row
      end
    end
  end
  
  def getAdGroups
    adwords = CSV.foreach("#{@filename}", headers:true) do |row|
      adGroup = row['Ad Group']
      #If Ad Group hasn't been collected yet, add it to the array
      if (@adGroups.include? adGroup) || (adGroup.nil?)
        next
      else
        @adGroups << adGroup
      end
    end
  end
  
  def getAdGroupData
    adwords = CSV.foreach("#{@filename}", headers:true) do |row|
      #Get the first data row for each Ad Group in the CSV
      if !(row['Ad Group Type'].nil?)
        @agData[row['Ad Group']] = row
      end
    end
  end
  
  def mapAdGroups
    adwords = CSV.foreach("#{@filename}", headers:true) do |row|
      if (@agMap[row['Campaign']].nil?)
        @agMap[row['Campaign']] = []
      end
      #for @agMap hash: Key = Campaign, Value = Ad Group
      if !(@agMap[row['Campaign']].include? row['Ad Group']) & !(row['Ad Group'].nil?)
        @agMap[row['Campaign']] << row['Ad Group']
      end
    end
  end
  
  def getAds
    adwords = CSV.foreach("#{@filename}", headers:true) do |row|
      ad = []
      if (@ads[row['Ad Group']].nil?)
        @ads[row['Ad Group']] = []
      end
      #Add select components of text ads to the array, then add the array to the @ads hash
      if !(row['Headline'].nil?) & !(row['Display URL'].nil?) & !(row['Description Line 1'].nil?) & !(row['Description Line 2'].nil?) & !(row['Final URL'].nil?)
        ad << row['Headline']
        ad << row['Display URL']
        ad << row['Description Line 1']
        ad << row['Description Line 2']
        ad << row['Final URL']
        @ads[row['Ad Group']] << ad
      end
    end
  end
  
  def getKeywords
    adwords = CSV.foreach("#{@filename}", headers:true) do |row|
      kwData = []
      if (@kws[row['Ad Group']].nil?)
        @kws[row['Ad Group']] = []
      end
      #Add select components of keywords to the array, then add the array to the @kws hash
      if !(row['Keyword'].nil?) & !(row['Criterion Type'].nil?) & !(row['Criterion Type'].to_s.include? "Negative")
        kwData << row['Keyword']
        kwData << row['Criterion Type']
        if (row['Max CPC'].nil?)
          kwData << "0"
        else
          kwData << row['Max CPC']
        end
        @kws[row['Ad Group']] << kwData
      end
    end
  end
  
  def getNegatives
    adwords = CSV.foreach("#{@filename}", headers:true) do |row|
      negData = []
      if (@negs[row['Ad Group']].nil?)
        @negs[row['Ad Group']] = []
      end
      if !(row['Keyword'].nil?) & !(row['Criterion Type'].nil?) & (row['Criterion Type'].to_s.include? "Negative")
        negData << row['Keyword']
        negData << row['Criterion Type']
        @negs[row['Ad Group']] << negData
      end
    end
  end
  
end

def main
  tst = AdwordsParser.new("Lighthouse Insurance+2015-11-02.csv")
  tst.parseCampaigns()
  for i in 0...tst.campaigns.length
    campaign = tst.campaigns[i]
    adgroups = tst.agMap[campaign]
    puts tst.campData[campaign]
    for j in 0...adgroups.length
      adgroup = adgroups[j]
      puts tst.agData[adgroup]
      for k in 0...tst.ads[adgroup].length
        puts tst.ads[adgroup][k][0]
        puts tst.ads[adgroup][k][1]
        puts tst.ads[adgroup][k][2]
        puts tst.ads[adgroup][k][3]
        puts tst.ads[adgroup][k][4]
      end
      for m in 0...tst.kws[adgroup].length
        puts tst.kws[adgroup][m][0]
        puts tst.kws[adgroup][m][1]
        puts tst.kws[adgroup][m][2]
      end
      for n in 0...tst.negs[adgroup].length
        puts tst.negs[adgroup][n][0]
        puts tst.negs[adgroup][n][1]
      end
    end
  end
end
