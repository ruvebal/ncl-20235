<?php

///////
////
//
// tei CLASS
//

class tei extends transform {

  private static $instance;
  private static $langCurr;


  ////
  //
  // tei:langCheck
  //

  function langCheck() {
    
    if (empty(self::$langCurr)) :
      self::$langCurr = $_SESSION['langCurr'];
    endif;
    
  } // EOFunction
  

  ////
  //
  
  function getChunk ($chunk = NULL,
		     $byLang = FALSE,
		     $output = 'html') {
    

    if ($byLang != FALSE) :

      // Set current language
      
      self::$langCurr = (is_bool($byLang)) ?
	self::langCheck() :
      $byLang;
    
    // Slice it
    
    $query = "//xmlns:TEI[@xml:lang='".self::$langCurr."']";

    self::$instance = $this->sliceXPath($query);

    endif;
    
    
    //

    switch ($chunk) {

    case FALSE: // Do not slice

      break;


    case 'root': 
      
      $query = "/*";
    
    }

    $doc = new DOMDocument();
    $doc->load($instance);
    
    $query = "//xmlns:TEI[@xml:lang='".self::$langCurr."']";
    $xpath = new DOMXPath($doc);
    $xpath->registerNamespace("xmlns",
			      "http://www.tei-c.org/ns/1.0");
    $nodeList = $xpath->query($query);
        
    if ($nodeList->length == 0) {

      return $this->instanceByLang($GLOBALS['noTranslation']);
      die('no translation'); 

    } else {

      $newDoc = new DOMDocument('1.0','UTF-8');
      
      foreach ($nodeList as $node) {
	$newDocNode = $newDoc->importNode($node, true);
	$newDoc->appendChild($newDocNode);
      }
      
    }
        
    ////    
    //
    // Output
    //

    switch ($output){
      
    case 'html' :

      $obj = new transform;
      return $obj->DOMXslt($newDom);
      
      break;
  

    case 'file' :

      // Is not working at my machine because a permissions problem... 
      // echo 'Wrote: ' . $newDom->save('newDOM.xml') . ' bytes';

      break;


    case 'xml' :
      
      return $newDom;      
      break;      
    }
    
  } // EOFunction
  

  ////
  //
  // tei::getMenu
  //

  function getMenu($instance) {
    
    $instance = $obj2->instanceByLang($GLOBALS['contentsPath'] . '/contract.tei',
				      $output='xml' );
  } // EOFunction
  
} // EOClass

?>