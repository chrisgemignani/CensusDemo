package {
  import flare.data.converters.DelimitedTextConverter;
  
  import mx.collections.ArrayCollection;
  import mx.events.CollectionEvent;
  import mx.rpc.events.ResultEvent;
  import mx.rpc.http.HTTPService;


  [Bindable]
  public class DataFromURL {
    /**
     * The number of accesses of <code>result</code>
     * for performance and debugging purposes.
     */
    public var resultFetches:int = 0;
    // Number of times the result had to be calculated

    /**
     * The number of times <code>query</code> had to be
     * evaluated, for performance and debugging purposes.
     */
    public var resultCalculations:int = 0;

    /**
     * The number of milliseconds it took to evaluate
     * <code>query</code> during the most recent eval.
     *
     * @default 'NA'
     */
    public var evalTime:String = 'NA';

    /**
     * A flag that stores if <code>result</code> needs to
     * be recalculated.
     */
    private var dirty:Boolean = true;


    /**
    * The maximum number of rows to return. Zero means return all.
    * 
    * @default 0
    */
    public var limit:uint = 0;    
    
    /**
    * A filter to run on the returned rows. Only rows that pass are included. 
    * 
    * filterFunction is evaluated after <code>limit</code>
    * 
    * filterFunction has the signature <code>function filterFunction(o:Object):Boolean</code>.
    */
    public var filterFunction:Function = null;

    /**
    * A filter to run to calculate additional fields. 
    * 
    * filterFunction is evaluated after <code>limit</code> and <code>filterFunction</code>
    * 
    * postprocess has the signature <code>private function postprocess(element:String, index:int, array:Array):void</code>.
    */
    public var postprocess:Function = null;

    private function propertyChanged():void {
      resultFetches += 1;
      if (url != null) {
        httpService.url = url;
        httpService.send();
      }
    }

    public function DataFromURL() {
      httpService = new HTTPService();
      httpService.method = "GET";
      httpService.resultFormat = "text";
      httpService.addEventListener(ResultEvent.RESULT, resultHandler);
      propertyChanged();
    }

    private function resultHandler(event:ResultEvent):void {
      var d:Array = delimitedTextConverter.parse(event.result as String).nodes.data;
      if (limit > 0) { 
        d = d.slice(0, limit); 
      }
      if (filterFunction != null) {
        d = d.filter(filterFunction);
      }
      if (postprocess != null) {
        d.forEach(postprocess);
      }
      result.source = d;
      
      result.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
    }
   
    
    public function set delimiter(v:String):void { delimitedTextConverter.delimiter = v; propertyChanged() }
    public function get delimiter():String { return delimitedTextConverter.delimiter }
    
    private var delimitedTextConverter:DelimitedTextConverter = new DelimitedTextConverter(',')
    private var httpService:HTTPService;
    
    public function set url(v:String):void { _url = v; propertyChanged(); }
    public function get url():String { return _url; }
    private var _url:String;
    
    public var result:ArrayCollection = new ArrayCollection([]);

  }
}