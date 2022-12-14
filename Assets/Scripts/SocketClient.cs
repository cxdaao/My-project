using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Net.Sockets;
using System.Net;
using System.Text;

public class SocketClient : MonoBehaviour
{
    private Socket tcpClient;
    private string serverIP = "127.0.0.1";//这个ip用自己电脑ip
    private int serverPort = 5000;

    // Start is called before the first frame update
    void Start()
    {
        //1.创建一个Socket
        tcpClient = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

        //2.建立连接请求
        IPAddress ipaddress = IPAddress.Parse(serverIP);
        EndPoint endPoint = new IPEndPoint(ipaddress, serverPort);
        tcpClient.Connect(endPoint);
        Debug.Log("请求服务器连接");

        //3.接受/发送消息
        byte[] data = new byte[1024];
        int length = tcpClient.Receive(data);
        var message = Encoding.UTF8.GetString(data, 0, length);
        Debug.Log("客户端接收到服务器发来的消息:" + message);


        //发送消息
        string message2 = "Client Say To Server Hello";
        tcpClient.Send(Encoding.UTF8.GetBytes(message2));
        Debug.Log("客户端向服务器发送消息"+message2);
        


    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
