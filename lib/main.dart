import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NeoLoopApp());
const bg = Color(0xFF061226), panel = Color(0xFF0C1E39), cyan = Color(0xFF38D8FF);
const palette = [Color(0xFFFF5577), Color(0xFF31DCA5), Color(0xFFFFC94A), Color(0xFF4BA7FF)];

class NeoLoopApp extends StatelessWidget {
  const NeoLoopApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'NeoLoop', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: cyan, brightness: Brightness.dark), useMaterial3: true),
    home: const HomePage());
}
class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage> {
 int level=1, completed=0; bool music=true, effects=true, ads=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load() async {final p=await SharedPreferences.getInstance();if(!mounted)return;setState((){
 level=p.getInt('level')??1;completed=p.getInt('completed')??0;music=p.getBool('music')??true;effects=p.getBool('effects')??true;ads=p.getBool('ads')??true;});}
 Future<void> _save() async {final p=await SharedPreferences.getInstance();await p.setInt('level',level);await p.setInt('completed',completed);await p.setBool('music',music);await p.setBool('effects',effects);await p.setBool('ads',ads);}
 Future<void> _play() async {final result=await Navigator.push<int>(context,MaterialPageRoute(builder:(_)=>GamePage(number:level)));
 if(result!=null&&mounted){setState((){completed=completed<result?result:completed;level=result<30?result+1:30;});await _save();}}
 @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 const SizedBox(height:25),Row(children:[Container(width:54,height:54,decoration:BoxDecoration(gradient:const LinearGradient(colors:[cyan,Color(0xFF8B5CFF)]),borderRadius:BorderRadius.circular(17)),child:const Icon(Icons.all_inclusive,size:35)),
 const SizedBox(width:12),const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('NeoLoop',style:TextStyle(fontSize:34,fontWeight:FontWeight.w900)),Text('Простые ходы. Бесконечное удовольствие.',style:TextStyle(color:Colors.white70,fontSize:11))])]),
 const Spacer(),Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(28),border:Border.all(color:cyan.withValues(alpha: .35))),
 child:Column(children:[const Icon(Icons.blur_circular,size:75,color:cyan),Text('УРОВЕНЬ $level',style:const TextStyle(color:cyan,letterSpacing:2,fontWeight:FontWeight.bold)),const SizedBox(height:10),
 const Text('Соедини одинаковые цвета',textAlign:TextAlign.center,style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),Text('Пройдено уровней: $completed из 30',style:const TextStyle(color:Colors.white70)),
 const SizedBox(height:20),FilledButton(onPressed:_play,style:FilledButton.styleFrom(backgroundColor:cyan,foregroundColor:bg,minimumSize:const Size.fromHeight(54)),child:const Text('ИГРАТЬ',style:TextStyle(fontWeight:FontWeight.w900)))])),
 const SizedBox(height:14),OutlinedButton.icon(onPressed:()async{await Navigator.push(context,MaterialPageRoute(builder:(_)=>SettingsPage(music:music,effects:effects,ads:ads,onSave:(m,e,a)async{setState((){music=m;effects=e;ads=a;});await _save();})));},icon:const Icon(Icons.settings),label:const Text('Настройки')),
 const Spacer(),const Text('MVP • Офлайн • Сохранение прогресса',textAlign:TextAlign.center,style:TextStyle(color:Colors.white38,fontSize:11))
]))));
}
class GamePage extends StatefulWidget {final int number;const GamePage({super.key,required this.number});@override State<GamePage> createState()=>_GamePageState();}
class _GamePageState extends State<GamePage>{
 final int w=5,h=5; final Map<int,List<int>> paths={}; int? active; List<int> draft=[]; int moves=0;
 final endpoints=const <int,int>{0:0,24:0,4:1,20:1,2:2,22:2};

int? colorFor(int c) {
  for (final e in endpoints.entries) {
    if (e.key == c) {
      return e.value;
    }
  }
  for (final e in paths.entries) {
    if (e.value.contains(c)) {
      return e.key;
    }
  }
  if (draft.contains(c)) {
    return active;
  }
  return null;
}

void begin(int c) {
  if (endpoints.containsKey(c)) {
    setState(() {
      active = endpoints[c];
      draft = [c];
      paths.remove(active);
    });
  } else {
    for (final e in paths.entries) {
      if (e.value.contains(c)) {
        setState(() {
          active = e.key;
          draft = [c];
          paths.remove(e.key);
        });
        break;
      }
    }
  }
}
 void moveTo(int c){if(active==null||draft.isEmpty||draft.contains(c))return;final last=draft.last;if((last%w-c%w).abs()+(last~/w-c~/w).abs()!=1)return;if(colorFor(c)!=null&&colorFor(c)!=active)return;setState((){draft.add(c);moves++;if(endpoints[c]==active&&c!=draft.first){paths[active!]=List.of(draft);active=null;draft=[];if([0,1,2].every(paths.containsKey)){showDialog(context:context,barrierDismissible:false,builder:(ctx)=>AlertDialog(backgroundColor:panel,title:const Text('Уровень пройден! ✨'),content:Text('Ходов: $moves'),actions:[TextButton(onPressed:(){Navigator.pop(ctx);Navigator.pop(context,widget.number);},child:const Text('ДАЛЕЕ'))]));}}});}
 void reset()=>setState(() { paths.clear(); active=null; draft=[]; moves=0; });
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text('Уровень ${widget.number}'),actions:[IconButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Подсказка: начните с цветного блока в углу.'))),icon:const Icon(Icons.lightbulb_outline)),IconButton(onPressed:reset,icon:const Icon(Icons.refresh))]),
 body:Column(children:[const Padding(padding:EdgeInsets.all(16),child:Text('Проведи пальцем по соседним клеткам, чтобы соединить одинаковые цвета.',textAlign:TextAlign.center)),
 Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:Padding(padding:const EdgeInsets.all(12),child:LayoutBuilder(builder:(context,box){final cw=box.maxWidth/w,ch=box.maxHeight/h;
 return GestureDetector(onPanStart:(d){final x=(d.localPosition.dx/cw).floor(),y=(d.localPosition.dy/ch).floor();if(x>=0&&x<w&&y>=0&&y<h)begin(y*w+x);},
 onPanUpdate:(d){final x=(d.localPosition.dx/cw).floor(),y=(d.localPosition.dy/ch).floor();if(x>=0&&x<w&&y>=0&&y<h)moveTo(y*w+x);},
 onPanEnd:(_){if(active!=null&&draft.length>1&&endpoints[draft.last]==active){setState(() { paths[active!]=List.of(draft); active=null; draft=[]; });}},
 child:CustomPaint(painter:GridPainter(w:w,h:h,endpoints:endpoints,paths:paths,draft:draft,active:active),child:const SizedBox.expand()));}))))),
 Padding(padding:const EdgeInsets.all(18),child:Row(children:[Expanded(child:OutlinedButton(onPressed:reset,child:const Text('Сначала'))),const SizedBox(width:12),Expanded(child:FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Подсказка: соединяйте блоки одного цвета.'))),child:const Text('Подсказка')))]))]));
}
class GridPainter extends CustomPainter{
 final int w,h;final Map<int,int>endpoints;final Map<int,List<int>>paths;final List<int>draft;final int?active;
 GridPainter({required this.w,required this.h,required this.endpoints,required this.paths,required this.draft,required this.active});
 @override void paint(Canvas canvas,Size s){final cw=s.width/w,ch=s.height/h;canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero&s, const Radius.circular(18)),Paint()..color=panel);
 final grid=Paint()..color=const Color(0xFF24415F)..style=PaintingStyle.stroke;
 for(int y=0;y<h;y++){for(int x=0;x<w;x++){canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x*cw+2,y*ch+2,cw-4,ch-4),const Radius.circular(7)),grid);}}
 void line(List<int> p,Color color){if(p.isEmpty)return;final path=Path();for(int i=0;i<p.length;i++){final c=p[i];final o=Offset((c%w+.5)*cw,(c~/w+.5)*ch);if(i==0)path.moveTo(o.dx,o.dy);else path.lineTo(o.dx,o.dy);}canvas.drawPath(path,Paint()..color=color..strokeWidth=cw*.18..strokeCap=StrokeCap.round..style=PaintingStyle.stroke);}
 for(final e in paths.entries)line(e.value,palette[e.key]);if(active!=null)line(draft,palette[active!]);
 for(final e in endpoints.entries){final o=Offset((e.key%w+.5)*cw,(e.key~/w+.5)*ch);canvas.drawCircle(o, cw * .25, Paint()..color = palette[e.value].withValues(alpha: .25));canvas.drawCircle(o,cw*.18,Paint()..color=palette[e.value]);canvas.drawCircle(o,cw*.07,Paint()..color=Colors.white);}
 }
 @override bool shouldRepaint(covariant GridPainter old)=>true;
}
class SettingsPage extends StatefulWidget{final bool music,effects,ads;final Future<void> Function(bool,bool,bool) onSave;const SettingsPage({super.key,required this.music,required this.effects,required this.ads,required this.onSave});@override State<SettingsPage> createState()=>_SettingsPageState();}
class _SettingsPageState extends State<SettingsPage>{late bool m,e,a;@override void initState(){super.initState();m=widget.music;e=widget.effects;a=widget.ads;}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Настройки')),body:ListView(children:[
 SwitchListTile(title:const Text('Музыка'),value:m,onChanged:(v)async{setState(()=>m=v);await widget.onSave(m,e,a);}),
 SwitchListTile(title:const Text('Звуковые эффекты'),value:e,onChanged:(v)async{setState(()=>e=v);await widget.onSave(m,e,a);}),
 const Divider(),SwitchListTile(title:const Text('Рекламные форматы разрешены'),subtitle:const Text('Заглушка: реальные объявления не подключены'),value:a,onChanged:(v)async{setState(()=>a=v);await widget.onSave(m,e,a);}),
 const Padding(padding:EdgeInsets.all(16),child:Text('Для управления рекламой в установленной игре требуется защищённый сервер.'))]));}
