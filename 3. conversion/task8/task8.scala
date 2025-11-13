import scala.xml._
import java.io._

object XmlToYaml {

  // Convert XML Node to Map[String, Any]
  def xmlNodeToMap(node: Node): Any = {
    if (node.child.isEmpty || node.child.forall(_.isInstanceOf[Text])) {
      node.text.trim
    } else {
      val grouped = node.child
        .filter(_.isInstanceOf[Elem])
        .groupBy(_.label)
        .map { case (label, nodes) =>
          if (nodes.size == 1) label -> xmlNodeToMap(nodes.head)
          else label -> nodes.map(xmlNodeToMap)
        }
      grouped
    }
  }

  // Convert Map/Any to YAML string with indentation
  def mapToYaml(data: Any, indent: Int = 0): String = {
    val pad = " " * indent
    data match {
      case m: Map[_, _] =>
        m.map {
          case (k, v) => pad + k.toString + ": " + (v match {
            case _: Map[_, _] | _: Seq[_] => "\n" + mapToYaml(v, indent + 2)
            case _ => v.toString
          })
        }.mkString("\n")
      case s: Seq[_] =>
        s.map {
          case elem: Map[_, _] => pad + "-\n" + mapToYaml(elem, indent + 2)
          case elem => pad + "- " + elem.toString
        }.mkString("\n")
      case other => pad + other.toString
    }
  }

  def main(args: Array[String]): Unit = {
    if (args.length < 1) {
      println("Usage: scala XmlToYaml.scala <input_file.xml>")
      sys.exit(1)
    }

    val inputFile = args(0)
    val xml = XML.loadFile(inputFile)
    val data = xmlNodeToMap(xml)
    val yamlString = mapToYaml(data)

    val outputFile = "output.yaml"
    val pw = new PrintWriter(new File(outputFile))
    pw.write(yamlString)
    pw.close()

    println(s"Conversion complete. YAML saved to $outputFile")
  }
}
