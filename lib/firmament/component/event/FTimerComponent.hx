
package firmament.component.event;

import firmament.util.FLog;
import firmament.component.base.FEntityComponent;
import firmament.core.FConfig;
import firmament.core.FEntity;
import firmament.core.FEvent;
import firmament.process.timer.FTimer;
/*
    Class: FEventMapperComponent
    maps events on the entity of a type to another event of a different type.
*/
class FTimerComponent extends FEntityComponent{
    

    var timer:FTimer;
    public function new(){
        super();
        
    }

    override public function init(config:FConfig){
        var startOn:String = config.get('startOn',String);

        var startTimerFunc = function(E:FEvent=null){
            var tm = _entity.getGameInstance().getGameTimerManager();
            timer = tm.addTimer(config.getNotNull('seconds',Float),this.triggerOnExpire,this);
        }

        //start timer now unless specified
        if(startOn == null && _entity.isActive()){
            FLog.debug("Starting timer");
            startTimerFunc();
        }else{
            FLog.debug("Delaying timer start");
            _entity.on(startOn,this,startTimerFunc);
        }

        //pause and unpause the timer as the entity changes active states
        _entity.on(FEntity.ACTIVE_STATE_CHANGE,this,function(e:FEvent){
            if(_entity.isActive()){
                if(config.get('startOn',String)==null){
                    FLog.debug("Starting timer");
                    startTimerFunc();
                }
            
            }else{
                if(timer!=null) {
                    FLog.debug("Stopping timer");
                    timer.cancel();
                }
                timer = null;
            }
        });

    }

    override public function getType(){
        return "timer";
    }

    private function triggerOnExpire(){
        _entity.trigger(new FEvent(this._config.getNotNull('trigger',String)));
    }
}