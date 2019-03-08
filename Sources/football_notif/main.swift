
import Foundation
import SwiftSoup

var result_string = ""
var diff_string=""
var timer: Timer!
var base_url="http://www.goaloo.com/CalcTime.aspx?"
var isFinished=false

/*
 Implementing: corner api
 http://data.goaloo.com/history/corner.aspx?id={id}&companyid=8
 */
func get_corner(id:String)
{
    
  //  print(try "corner:"+(doc.select("td tr")).get(2).text())
}

func get_match_status(match_id:String)
{
    let myURLString = base_url+match_id
    guard let myURL = URL(string: myURLString) else {
        print("Error: \(myURLString) doesn't seem to be a valid URL")
        return
    }
    do {
        result_string = try String(contentsOf: myURL, encoding: .ascii)
        //crawl
        do {
            
            let doc: Document = try SwiftSoup.parse(result_string)
            let temp_str = try doc.select("font").text()
            if(temp_str=="Finished")
            {
                isFinished=true;
                let task = Process()
                task.launchPath = "/usr/bin/osascript"
                
                
                let arg = "-e "+"display notification \""+diff_string+"\" sound name \"Glass\" with title \"Full time\" "
                
                
                task.arguments = [arg]
                
                task.launch()
            }
        } catch Exception.Error(let type, let message) {
            print(message)
            
        } catch {
            print("error")
        }
        //stop
    } catch let error {
        print("Error: \(error)")
    }
    
}

func crawler(url:String){
    
    let myURLString = url
    URLCache.shared.removeAllCachedResponses()
    guard let myURL = URL(string: myURLString) else {
        print("Error: \(myURLString) doesn't seem to be a valid URL")
        return
    }
    do {
        result_string = try String(contentsOf: myURL, encoding: .ascii)
        //crawl
        do {
            
            let doc: Document = try SwiftSoup.parse(result_string)
            let temp_str = try doc.select("div#home .name").text()+" "+doc.select("span.b.t15").text()+" "+doc.select("div#guest .name").text()
            
            //jsData/(0,2)/(2,4)/id.js?v=1
            let match_status = try base_url+doc.select("strong script").attr("src")
            
            let malform = match_status.components(separatedBy: "&")
            
            //doc diff than string : match score change
            if (try temp_str != diff_string)
            {
                
                print("\u{001B}[2J")
                diff_string=try temp_str
                let task = Process()
                task.launchPath = "/usr/bin/osascript"
                print(diff_string)
                
                let arg = "-e "+"display notification \""+diff_string+"\" sound name \"default\" with title \"Goal\" "
                
                
                task.arguments = [arg]
                
                task.launch()
                
            }
            if(!isFinished)
            {
               get_match_status(match_id: malform[2])
            }
        } catch Exception.Error(let type, let message) {
            print(message)
            
        } catch {
            print("error")
        }
        //stop
    } catch let error {
        print("Error: \(error)")
    }
   
}
print("Enter futbol link:")
let response = readLine()
while(true)
{
    
    DispatchQueue.global(qos: .background).async {
        crawler(url:response!)
    }
     sleep(10)
    if(isFinished)
    {
        exit(0)
    }
}

