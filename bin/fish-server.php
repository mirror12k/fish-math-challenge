<?php
                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                            
                                                                                                                                      $m=[                                                                                                                  
                                                                                                                                    "Look",                                                                                                                 
                                                                                                                                "at","you,",                                                                                                                
                                                                                                                              "hacker:","a",/**/                                                                                                            
                                                                                                                            "pathetic","creature",                                                                                                          
                                                                                                                          "of","meat","and",/****/                                                                                                          
                                                                                                                        "bone,","panting","and",/**/                                                                                                        
                                                                                                                      "sweating","as","you","run",/****/                                                                                                    
                                                                                                                    "through","my","corridors.","How",/**/                                                                                                  
                                                                                                                  "can","you","challenge","a","perfect,",                                                                                                   
                                                                                  "immortal","machine?",];$r='https://en.wikipedia.org/wiki/Red_herring';/***/                                                                                function      
                                                          obfuscate($data,$a){$pr='preg'.'_replace'.'_callback';$a=$pr('/[^ \n]+/',function ($m){return '['.(/***/                                                                      strlen($m[0])/1)    
                                              .']';},$a);$a=$pr('/ +/',function ($m){return '{'.strlen($m[0]).'}';},$a);error_log("$a");$data=str_replace('/1',                                                                     '/1',$data);$ts=[]      
                                        ;foreach(token_get_all($data) as$t){if(!is_array($t))$ts[]=$t;else {$n=token_name($t[0]);if(($n!=='T_COMMENT'&&                                                                       $n!=='T_WHITESPACE'&&         
                                  $n!=='T_OPEN_TAG')&&$t[1]==='as'){$ts[]=' ';$ts[]=$t[1];}else if(($n!=='T_COMMENT'&&$n!=='T_WHITESPACE'&&$n!=='T_OPEN_TAG')||($t                                                        [1]===' '&&preg_match(            
                            '/\A(return|function|else)\Z/',$ts[count($ts)-1])))$ts[]=$t[1];}}$e=function ($l)use(&$ts){$s='';while(count($ts)>0&&strlen($ts[0])<=$l){$l-=                                             strlen($ts[0]);$s.=/*****/            
                      array_shift($ts);}if($l>=4)$s.='/'.str_repeat('*',$l-2).'/';else$s.=str_repeat(' ',$l);return $s;};$a=$pr('/\[(\d+)\]/',function ($m)use($e){return $e((int)$m[1])                            ;},$a);$a=$pr(/**********/              
                '/\{(\d+)\}/',function ($m){return str_repeat(' ',(int)$m[1]);},$a);print("<?php\n");print("$a");}function execute_api($text){$unique=uniqid();error_log("unique: $unique");/******/            file_put_contents(/********/                
          "./temp_files/testinput.".$unique.".txt",$text);$commands=[['validator',"./temp_files/testinput.".$unique.".txt","./python_math/PythonMathValidator.pm ./temp_files/testinput.".$unique.".txt",false],['executor',/************/                  
    "./temp_files/testinput.".$unique.".txt","cd python_executor/ && cat ../temp_files/testinput.".$unique./*****************************/      ".txt | ./Dockerfile timeout 5s python3 2>&1",true],['detonator',/*********************/                    
  "./temp_files/testoutput.".$unique.".txt",/********/  /********/                                                                /************/      /****/      "cd chrome_docker/ && cat ../temp_files/testoutput.".$unique./*******/                    
  /************************************************/                                                                                                            /****/    ".txt | ./Dockerfile ./ephemeral-x.sh ./script.html",false],                      
];for($i=0;$i<count($commands);$i++){$output=null;                                                                                                                                      $retval=null;exec($commands[$i][2],$output,/***/                    
$retval);$output=implode("\n",$output);error_log(                                                                                                                                           /**/  $commands[$i][0]." output [$retval]: [[                   
  $output]]");if($retval!==0){foreach($commands as$com  )         unlink($com[1]);return ['success'=>false,   /**/  'stage'=>$commands[$i][0],      /******/      /**/  /****/  'command'=>$commands[$i][2],'output'=>$output,];}if($commands[              
      $i][3])file_put_contents($commands[$i+1][1],$output);}$contents=file_get_contents($commands[2][1]);foreach($commands as$com)unlink($com[1]);if(preg_match('/msg=([a-zA-Z0-9\+-\/=]*)/',$output,$matches)&&$matches[1]!=='fail'){return [              
          'success'=>true,'msg'=>$contents,'stage'=>$commands[2][0],'command'=>$commands[2][2],'output'=>$output,];}else {return ['success'=>false,'error'=>'detected unsafe output!'./********/                /********************************/          
              ' you might be under an XSS attack!','stage'=>$commands[2][0],'command'=>$commands[2][2],'output'=>$output,];}}function server(){error_log('query: '.$_SERVER['REQUEST_URI']);if(                       $_SERVER['REQUEST_URI']===/****/      
                    '/api/v1/execute'){$content=json_decode(file_get_contents('php://input'),true);error_log('got apikey: '.$content['apikey']);$cmpkey=(string)file_get_contents('apikey.txt'                            );$apikey=md5((string)$content    
                            ['apikey']);if($apikey!==$cmpkey){echo(json_encode(['success'=>false,'error'=>'invalid apikey']));return;}error_log('got content: '.$content['code']);echo(                                     json_encode(execute_api(/****/  
                                  (string)$content['code'])));}else {include"bin/main.html";}}if(!isset($argv))server();else if(count($argv)===2)obfuscate(file_get_contents($argv[0])                                            ,file_get_contents($argv[1
                                        ]));else while(1)shell_exec('php -S 0.0.0.0:8651 '.$argv[0]);/*********************************************************/      /**********/                                                                          
                                                /****************************************************************************************************/                  /****/                                                                              
                                                        /********************************************************************************************/                                                                                                      
                                                              /****************************************************************************************/                                                                                                    
                                                                  /**********/        /**************************/        /****************************/                                                                                                    
                                                                    /**********/                                                                                                                                                                            
                                                                        /********/                                                                                                                                                                          
                                                                            /******/                                                                                                                                                                        