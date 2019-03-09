
import Foundation
import SwiftSoup

var result_string = ""
var diff_string=""
var timer: Timer!
var base_url = "http://www.goaloo.com/CalcTime.aspx?id="
var corner_url = "http://data.goaloo.com/history/corner.aspx?companyid=8&id="
var isFinished=false

/*
 Implementing: corner api

 */
func get_corner(id:String)
{
    let myURLString = corner_url+id
    guard let myURL = URL(string: myURLString) else {
        print("Error: \(myURLString) doesn't seem to be a valid URL")
        return
    }
    print(id)
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

func get_goal(url:String){
    
    let myURLString = url
    
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

var id = (response! as NSString).lastPathComponent.components(separatedBy: ".")
print("1:Goal\n2:Corner\n3:Goal+Corner")
let selection = readLine()
while(true)
{
    
    DispatchQueue.global(qos: .background).async {
        //clean network cache
        URLCache.shared.removeAllCachedResponses()
        //check match status
        if(!isFinished)
        {
            
            get_match_status(match_id:id[0])
        }
        //goal/corner statuss
        switch(Int(selection!))
        {
        case 1:
            //goal only
            get_goal(url:response!)
        
            break;
        case 2:
            //corener only
            get_corner(id: id[0])
            break;
        case 3:
            //goal+corner
            break;
        default:
            break;
        }
    }
     sleep(10)
    if(isFinished)
    {
        exit(0)
    }
}

