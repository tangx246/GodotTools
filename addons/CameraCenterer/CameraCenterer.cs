using CommunityToolkit.Mvvm.Messaging;
using Godot;
using CameraMessages;

namespace CameraMessages
{
	public record CameraCenterMessage(Vector3 pos);
}

public partial class CameraCenterer : Node, IRecipient<CameraCenterMessage>
{
	[Export]
	public Node3D cameraObject;
	[Export]
	public Vector3 offset = new(0, 0, 0);

	public override void _EnterTree()
	{
		base._EnterTree();

		StrongReferenceMessenger.Default.RegisterAll(this);
	}

	public override void _ExitTree()
	{
		base._ExitTree();

		StrongReferenceMessenger.Default.UnregisterAll(this);
	}

	public void Receive(CameraCenterMessage message)
	{
		cameraObject.Position = message.pos + offset;
	}
}
