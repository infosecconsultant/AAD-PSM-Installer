using System;
using Microsoft.Azure.PowerShell.Cmdlets.ConnectedMachine.Runtime.Json;

namespace Microsoft.Azure.PowerShell.Cmdlets.ConnectedMachine.Models
{
    public partial class MachineExtensionProperties
    {
        private const string typeHandlerVersionPropertyName = "typeHandlerVersion";

    }

    /// <summary>Describes a Machine Extension.</summary>
    public partial class MachineExtensionUpdateProperties
    {
        private const string typeHandlerVersionPropertyName = "typeHandlerVersion";

        /// <summary>
        /// <c>AfterToJson</c> will be called after the json serialization has finished, allowing customization of the <see cref="Microsoft.Azure.PowerShell.Cmdlets.ConnectedMachine.Runtime.Json.JsonObject"
        /// /> before it is returned. Implement this method in a partial class to enable this behavior
        /// </summary>
        /// <param name="container">The JSON container that the serialization result will be placed in.</param>
        partial void AfterToJson(ref JsonObject container)
        {
            // The PATCH operation (aka Update) doesn't like when a version is specified so we remove it entirely.
            if (container.TryGetValue(typeHandlerVersionPropertyName, out JsonNode node))
            {
                container.Remove(typeHandlerVersionPropertyName);
            }
        }
    }
}
