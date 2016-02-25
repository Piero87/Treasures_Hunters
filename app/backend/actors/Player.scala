package backend.actors

import akka.actor.{ ActorRef, Actor }
import akka.actor.Props
import play.api.Logger
import play.api.libs.json._
import common._
import akka.pattern.ask
import scala.concurrent.duration._
import scala.concurrent.Future
import backend.actors.models._
import akka.actor._
import akka.util.Timeout

object Player {

  /**
   * Actor Props 
   */
  def props(uid: String, name: String, team: Int, area : Polygon, GMbackend: ActorRef): Props = Props(new Player(uid, name, team, area, GMbackend))
  
}

class Player(uid: String, name: String, team: Int, area : Polygon, GMbackend: ActorRef) extends Actor{
  
  val logger = new CustomLogger("PlayerActor")
  
  def receive = {
    case SetTrap(gold, pos) =>
      var origin = sender
      if (gold >= 100) {
        //Puoi mettere la trappola
        var new_gold = gold - 100
        origin ! NewTrap(uid,new_gold, pos)
      } else {
        origin ! MessageCode(uid, MsgCodes.NO_TRAP)
      }
    case OpenTreasure(treasures,user) =>
      
      var origin = sender
      implicit val ec = context.dispatcher
      val taskFutures: List[Future[Tuple3[Int,Key,Int]]] = treasures map { t =>
          implicit val timeout = Timeout(5 seconds)
          (t ? Open(user.pos,user.keys)).mapTo[Tuple3[Int,Key,Int]]
      }
      
      //The call to Future.sequence is necessary to transform the List of Future[(String, Int)] into a Future of List[(String, Int)].
      val searchFuture = Future sequence taskFutures
      
      searchFuture.onSuccess {
        case results: List[Tuple3[Int,Key,Int]] =>
          //Fare qualcosa
          logger.log("risultato apertura tesori")
          origin ! TreasureResponse(user.uid, results)
      }
    case IAttackYou(level) =>
      var origin = sender
      var gold_stolen = 0
      
       
  }
}