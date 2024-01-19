using System;
using Godot;

namespace GodotReactiveExtensions
{
    public static class IDisposableExtensions
    {
        public static void AddTo(this IDisposable disposable, Node node)
        {
            node.TreeExited += () => { disposable.Dispose(); };
        }
    }
}